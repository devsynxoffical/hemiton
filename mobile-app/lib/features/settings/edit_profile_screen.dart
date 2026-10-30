import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/services/personal_details_service.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Unique Bento-Glass Edit Profile Screen:
/// - Layered aurora hero header with glowing avatar & quick identity pills
/// - 2x2 Bento Grid for Gender, Date of Birth, Location (auto-detected), and Hometown (one-time locked)
/// - Sleek glass cards for Nickname, Username, and Bio with zero extra text clutter.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _avatarPath;
  late String _nickname;
  late String _username;
  late String _bio;
  late String _gender;
  DateTime? _dob;
  late String _location;
  late String _hometown;
  bool _isHometownLocked = false;
  bool _isLoading = true;
  bool _isDetectingLocation = false;

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
    'Mumbai, India',
    'Istanbul, Turkey',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = context.read<AuthProvider>().currentUser;
    _nickname = user.name.isNotEmpty && user.name != 'Guest'
        ? user.name
        : (user.username.isNotEmpty ? user.username : 'HEMI TON Member');
    _username = user.username.isNotEmpty ? user.username : 'user';
    _bio = user.bio.isNotEmpty ? user.bio : '';
    final gLower = user.gender.toLowerCase();
    _gender = gLower == 'female'
        ? 'Female'
        : (gLower == 'other' ? 'Other' : 'Male');
    _dob = user.dateOfBirth ?? DateTime(2002, 5, 15);

    final details = await PersonalDetailsService.instance.getDetails(user);
    _location = details.location.isNotEmpty ? details.location : 'Islamabad, Pakistan';
    _hometown = details.hometown;
    _isHometownLocked = details.isHometownLocked && _hometown.trim().isNotEmpty;

    if (mounted) {
      setState(() => _isLoading = false);
    }

    _autoDetectLocation(silent: true);
  }

  Future<void> _autoDetectLocation({bool silent = false}) async {
    if (_isDetectingLocation) return;
    if (!silent && mounted) {
      setState(() => _isDetectingLocation = true);
    }
    final detected = await PersonalDetailsService.instance.detectCurrentLocation();
    if (mounted) {
      setState(() {
        _location = detected;
        _isDetectingLocation = false;
      });
      await _saveChanges(showFeedback: !silent);
    }
  }

  Future<void> _saveChanges({bool showFeedback = false}) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    final currentDetails = await PersonalDetailsService.instance.getDetails(user);
    final updatedDetails = currentDetails.copyWith(
      location: _location,
      hometown: _hometown,
      isHometownLocked: _isHometownLocked,
    );
    await PersonalDetailsService.instance.saveDetails(user.id, updatedDetails);

    await auth.updateProfile(
      name: _nickname,
      username: _username,
      bio: _bio,
      gender: _gender,
      region: _location,
      birthDate: _dob,
      avatarUrl: _avatarPath,
    );

    if (showFeedback && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved ✨'),
          backgroundColor: const Color(0xFF8A2BE2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
    }
  }

  Future<void> _pickAvatar() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141624) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMediaPickerTile(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: const Color(0xFF00E5FF),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (file != null && mounted) {
                    setState(() => _avatarPath = file.path);
                    await _saveChanges(showFeedback: true);
                  }
                },
              ),
              _buildMediaPickerTile(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: const Color(0xFFFF007F),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
                  if (file != null && mounted) {
                    setState(() => _avatarPath = file.path);
                    await _saveChanges(showFeedback: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPickerTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130.w,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editBio() {
    final controller = TextEditingController(text: _bio);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141624) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 18.w,
          right: 18.w,
          top: 18.h,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 18.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bio',
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Bio...',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2132) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF007F),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 46.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () {
                setState(() => _bio = controller.text.trim());
                _saveChanges(showFeedback: true);
                Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _editTextValue(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141624) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 18.w,
          right: 18.w,
          top: 18.h,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 18.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: title,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2132) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF007F),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 46.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  onSave(text);
                  _saveChanges(showFeedback: true);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _selectGender() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141624) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gender', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2132) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: ['Male', 'Female', 'Other'].contains(_gender) ? _gender : 'Male',
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF1E2132) : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  items: const ['Male', 'Female', 'Other'].map((g) {
                    final icon = g == 'Female'
                        ? Icons.female_rounded
                        : (g == 'Male' ? Icons.male_rounded : Icons.transgender_rounded);
                    final color = g == 'Female'
                        ? const Color(0xFFFF007F)
                        : (g == 'Male' ? const Color(0xFF00E5FF) : const Color(0xFF8A2BE2));
                    return DropdownMenuItem<String>(
                      value: g,
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            g,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.darkNavy,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _gender = val);
                      _saveChanges(showFeedback: true);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2002, 5, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked);
      await _saveChanges(showFeedback: true);
    }
  }

  void _handleHometownTap() {
    if (_isHometownLocked && _hometown.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Hometown is locked after one-time selection.')),
            ],
          ),
          backgroundColor: const Color(0xFF1E2132),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customController = TextEditingController();
    String selectedTemp = _hometown.isNotEmpty ? _hometown : _popularHometowns.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141624) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 18.w,
            right: 18.w,
            top: 18.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 18.h,
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
                      const Icon(Icons.home_work_rounded, color: Color(0xFFFF007F)),
                      SizedBox(width: 8.w),
                      Text(
                        'Select Hometown',
                        style: GoogleFonts.poppins(fontSize: 15.5.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.amber, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '1-Time',
                          style: TextStyle(color: Colors.amber, fontSize: 10.5.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: customController,
                onChanged: (val) {
                  if (val.trim().isNotEmpty) {
                    setModalState(() => selectedTemp = val.trim());
                  }
                },
                decoration: InputDecoration(
                  hintText: 'City...',
                  prefixIcon: const Icon(Icons.location_city_rounded, size: 18),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2132) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 150.h,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _popularHometowns.map((city) {
                      final isSelected = selectedTemp == city;
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF007F).withValues(alpha: 0.22),
                        labelStyle: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected
                              ? const Color(0xFFFF007F)
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          customController.clear();
                          setModalState(() => selectedTemp = city);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF007F),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 46.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text('Lock Hometown', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (selectedTemp.trim().isEmpty) return;
                  setState(() {
                    _hometown = selectedTemp.trim();
                    _isHometownLocked = true;
                  });
                  _saveChanges(showFeedback: true);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDob(DateTime? date) {
    if (date == null) return '2002-05-15';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 21;
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age > 0 ? age : 18;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0816) : const Color(0xFFF6F8FC),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFFF007F))),
      );
    }

    final avatarProvider = _avatarPath != null
        ? FileImage(File(_avatarPath!)) as ImageProvider
        : (user.avatarUrl.isNotEmpty
            ? NetworkImage(user.avatarUrl)
            : const NetworkImage(
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
              ));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0816) : const Color(0xFFF6F8FC),
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
          'Edit Profile',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            // ── 1. Unique Layered Aurora Identity Banner ────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF21123A), const Color(0xFF141128), const Color(0xFF0E1B2E)]
                      : [const Color(0xFFFCE7F3), const Color(0xFFEDE9FE), const Color(0xFFE0F2FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFFFF007F).withValues(alpha: 0.28),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A2BE2).withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.all(18.w),
              child: Row(
                children: [
                  // Glowing Multi-Ring Avatar
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 82.w,
                          height: 82.w,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF007F), Color(0xFF8A2BE2), Color(0xFF00E5FF)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF007F).withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(image: avatarProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Icon(Icons.camera_alt_rounded, size: 12.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Identity Info & Quick Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _editTextValue(
                            'Nickname',
                            _nickname,
                            (v) => setState(() => _nickname = v),
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _nickname,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.darkNavy,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.edit_rounded, size: 14.sp, color: const Color(0xFFFF007F)),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        GestureDetector(
                          onTap: () => _editTextValue(
                            'Username',
                            _username,
                            (v) => setState(() => _username = v.replaceAll('@', '').toLowerCase()),
                          ),
                          child: Text(
                            '@$_username',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            _buildMiniBadge(
                              icon: _gender.toLowerCase() == 'female'
                                  ? Icons.female_rounded
                                  : Icons.male_rounded,
                              label: '${_calculateAge(_dob)}',
                              color: _gender.toLowerCase() == 'female'
                                  ? const Color(0xFFFF007F)
                                  : const Color(0xFF00E5FF),
                            ),
                            _buildMiniBadge(
                              icon: Icons.place_rounded,
                              label: _location.split(',').first,
                              color: const Color(0xFF00E676),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // ── 2. Bio Glass Capsule ────────────────────────────────────────
            GestureDetector(
              onTap: _editBio,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: _cardDecoration(isDark),
                child: Row(
                  children: [
                    _buildIconBox(Icons.auto_awesome_rounded, const Color(0xFFFF007F)),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bio',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _bio.isNotEmpty ? _bio : 'Add bio...',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: _bio.isNotEmpty
                                  ? (isDark ? Colors.white : AppColors.darkNavy)
                                  : (isDark ? Colors.white38 : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_note_rounded, color: const Color(0xFFFF007F), size: 20.sp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ── 3. Unique 2x2 Bento Grid (Gender, Birthday, Location, Hometown) ──
            Row(
              children: [
                Expanded(
                  child: _buildBentoTile(
                    isDark: isDark,
                    icon: _gender.toLowerCase() == 'female'
                        ? Icons.female_rounded
                        : Icons.male_rounded,
                    color: _gender.toLowerCase() == 'female'
                        ? const Color(0xFFFF007F)
                        : const Color(0xFF00E5FF),
                    label: 'Gender',
                    value: _gender,
                    onTap: _selectGender,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildBentoTile(
                    isDark: isDark,
                    icon: Icons.cake_rounded,
                    color: const Color(0xFFFF9800),
                    label: 'Birthday',
                    value: _formatDob(_dob),
                    badgeText: '${_calculateAge(_dob)}y',
                    onTap: _selectDateOfBirth,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _buildBentoTile(
                    isDark: isDark,
                    icon: Icons.my_location_rounded,
                    color: const Color(0xFF00E676),
                    label: 'Location',
                    value: _location,
                    trailingIcon: _isDetectingLocation ? null : Icons.gps_fixed_rounded,
                    isLoading: _isDetectingLocation,
                    onTap: () => _autoDetectLocation(silent: false),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildBentoTile(
                    isDark: isDark,
                    icon: Icons.home_work_rounded,
                    color: const Color(0xFFFFB300),
                    label: 'Hometown',
                    value: _hometown.isNotEmpty ? _hometown : 'Select',
                    trailingIcon: (_isHometownLocked && _hometown.isNotEmpty)
                        ? Icons.lock_rounded
                        : Icons.add_circle_outline_rounded,
                    onTap: _handleHometownTap,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // ── 4. Nickname & Username Quick Edit Card ──────────────────────
            Container(
              decoration: _cardDecoration(isDark),
              child: Column(
                children: [
                  _buildCompactRow(
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFF8A2BE2),
                    title: 'Nickname',
                    value: _nickname,
                    isDark: isDark,
                    onTap: () => _editTextValue(
                      'Nickname',
                      _nickname,
                      (v) => setState(() => _nickname = v),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 56.w,
                    endIndent: 16.w,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  _buildCompactRow(
                    icon: Icons.alternate_email_rounded,
                    iconColor: const Color(0xFF00E5FF),
                    title: 'Username',
                    value: '@$_username',
                    isDark: isDark,
                    onTap: () => _editTextValue(
                      'Username',
                      _username,
                      (v) => setState(() => _username = v.replaceAll('@', '').toLowerCase()),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoTile({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    String? badgeText,
    IconData? trailingIcon,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: _cardDecoration(isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconBox(icon, color),
                if (isLoading)
                  SizedBox(
                    width: 15.w,
                    height: 15.w,
                    child: CircularProgressIndicator(strokeWidth: 2, color: color),
                  )
                else if (badgeText != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  )
                else if (trailingIcon != null)
                  Icon(trailingIcon, color: color, size: 16.sp),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Icon(icon, color: color, size: 18.sp),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF151228) : Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildCompactRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      leading: _buildIconBox(icon, iconColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.darkNavy,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.grey.shade400, size: 18.sp),
        ],
      ),
      onTap: onTap,
    );
  }
}
