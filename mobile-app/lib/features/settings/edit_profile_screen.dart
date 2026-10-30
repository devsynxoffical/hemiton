import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/services/personal_details_service.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Redesigned Edit Profile Screen:
/// - Clean, modern ZeParty layout with extra fields (Height, Weight, Occupation, Traits, Hobbies) removed.
/// - Essential fields only:
///   1. Avatar Photo (Camera / Gallery)
///   2. Nickname & Username
///   3. Bio
///   4. Gender (Male / Female)
///   5. Date of Birth (DOB with age badge)
///   6. Location (Auto-detected according to user's current location)
///   7. Hometown (One-time selection only — permanently locked once set)
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
    _gender = (user.gender.toLowerCase() == 'female') ? 'Female' : 'Male';
    _dob = user.dateOfBirth ?? DateTime(2002, 5, 15);

    final details = await PersonalDetailsService.instance.getDetails(user);
    _location = details.location.isNotEmpty ? details.location : 'Islamabad, Pakistan';
    _hometown = details.hometown;
    _isHometownLocked = details.isHometownLocked && _hometown.trim().isNotEmpty;

    if (mounted) {
      setState(() => _isLoading = false);
    }

    // Auto-refresh location according to user's current location if default/empty
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
          content: const Text('Profile updated successfully! ✨'),
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF00E5FF)),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (file != null && mounted) {
                    setState(() => _avatarPath = file.path);
                    await _saveChanges(showFeedback: true);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFFFF1493)),
                title: const Text('Take a Photo'),
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
              'Edit Bio',
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              maxLines: 4,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Write a short bio about yourself...',
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
                backgroundColor: const Color(0xFFFF1493),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 46.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
              ),
              onPressed: () {
                setState(() => _bio = controller.text.trim());
                _saveChanges(showFeedback: true);
                Navigator.pop(ctx);
              },
              child: const Text('Save Bio', style: TextStyle(fontWeight: FontWeight.bold)),
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
              'Edit $title',
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter $title',
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
                backgroundColor: const Color(0xFFFF1493),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 46.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
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
            Text('Select Gender', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            ListTile(
              leading: const Icon(Icons.male_rounded, color: Color(0xFF29B6F6)),
              title: const Text('Male'),
              trailing: _gender.toLowerCase() == 'male'
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF1493))
                  : null,
              onTap: () {
                setState(() => _gender = 'Male');
                _saveChanges(showFeedback: true);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.female_rounded, color: Color(0xFFFF4081)),
              title: const Text('Female'),
              trailing: _gender.toLowerCase() == 'female'
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF1493))
                  : null,
              onTap: () {
                setState(() => _gender = 'Female');
                _saveChanges(showFeedback: true);
                Navigator.pop(ctx);
              },
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
              Expanded(
                child: Text('Hometown can only be selected once and cannot be changed.'),
              ),
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
                children: [
                  const Icon(Icons.home_work_rounded, color: Color(0xFFFF1493)),
                  SizedBox(width: 8.w),
                  Text(
                    'Select Hometown (One-Time Only)',
                    style: GoogleFonts.poppins(fontSize: 15.5.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Important: Hometown can only be selected once. After saving, it will be permanently locked.',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
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
                  hintText: 'Or type your hometown city...',
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
                height: 160.h,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _popularHometowns.map((city) {
                      final isSelected = selectedTemp == city;
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF1493).withValues(alpha: 0.22),
                        labelStyle: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected
                              ? const Color(0xFFFF1493)
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
                  backgroundColor: const Color(0xFFFF1493),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 46.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
                ),
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text(
                  'Confirm & Lock Hometown',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
    if (date == null) return '2002 / May / 15';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.year} / ${months[date.month - 1]} / ${date.day.toString().padLeft(2, '0')}';
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
        backgroundColor: isDark ? const Color(0xFF0C0E15) : const Color(0xFFF7F9FC),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFFF1493))),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E15) : const Color(0xFFF7F9FC),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            // ── Hero Avatar Header Card ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1A1530), const Color(0xFF121422)]
                      : [const Color(0xFFFDF2F8), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: const Color(0xFFFF1493).withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 94.w,
                          height: 94.w,
                          padding: EdgeInsets.all(3.w),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF1493), Color(0xFF8A2BE2), Color(0xFF00E5FF)],
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: _avatarPath != null
                                    ? FileImage(File(_avatarPath!)) as ImageProvider
                                    : (user.avatarUrl.isNotEmpty
                                        ? NetworkImage(user.avatarUrl)
                                        : const NetworkImage(
                                            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
                                          )),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(7.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF1493), Color(0xFF8A2BE2)],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.8),
                            ),
                            child: Icon(Icons.camera_alt_rounded, size: 14.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    _nickname,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    '@$_username',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // ── Bio Card ────────────────────────────────────────────────────
            _buildCardContainer(
              isDark: isDark,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                leading: _buildIconCircle(Icons.edit_note_rounded, const Color(0xFFFF1493)),
                title: Text(
                  'Bio',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    _bio.isNotEmpty ? _bio : 'Tap to write your bio...',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: _bio.isNotEmpty
                          ? (isDark ? Colors.white70 : Colors.black87)
                          : (isDark ? Colors.white38 : Colors.grey),
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
                onTap: _editBio,
              ),
            ),

            SizedBox(height: 14.h),

            // ── Personal Information Card (Nickname, Gender, DOB, Location, Hometown) ─
            _buildCardContainer(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 14.h, bottom: 4.h),
                    child: Text(
                      'Personal Details',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                    ),
                  ),
                  _buildDetailRow(
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
                  _buildDivider(isDark),
                  _buildDetailRow(
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
                  _buildDivider(isDark),
                  _buildDetailRow(
                    icon: _gender.toLowerCase() == 'female'
                        ? Icons.female_rounded
                        : Icons.male_rounded,
                    iconColor: _gender.toLowerCase() == 'female'
                        ? const Color(0xFFFF4081)
                        : const Color(0xFF29B6F6),
                    title: 'Gender',
                    value: _gender,
                    isDark: isDark,
                    onTap: _selectGender,
                  ),
                  _buildDivider(isDark),
                  _buildDetailRow(
                    icon: Icons.cake_rounded,
                    iconColor: const Color(0xFFFF9800),
                    title: 'Date of Birth',
                    value: '${_formatDob(_dob)} (${_calculateAge(_dob)} yrs)',
                    isDark: isDark,
                    onTap: _selectDateOfBirth,
                  ),
                  _buildDivider(isDark),

                  // Location Row (According to user's current location)
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                    leading: _buildIconCircle(Icons.my_location_rounded, const Color(0xFF00E676)),
                    title: Text(
                      'Location',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                    ),
                    subtitle: Text(
                      'According to your current location',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white38 : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isDetectingLocation)
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF00E676),
                            ),
                          )
                        else
                          Text(
                            _location,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00E676),
                            ),
                          ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.refresh_rounded,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                          size: 18.sp,
                        ),
                      ],
                    ),
                    onTap: () => _autoDetectLocation(silent: false),
                  ),

                  _buildDivider(isDark),

                  // Hometown Row (One-Time Selection Only — Locked Once Set)
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                    leading: _buildIconCircle(Icons.home_work_rounded, const Color(0xFFFFB300)),
                    title: Row(
                      children: [
                        Text(
                          'Hometown',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        if (_isHometownLocked && _hometown.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 10.sp, color: Colors.amber),
                                SizedBox(width: 3.w),
                                Text(
                                  'Locked',
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      _isHometownLocked && _hometown.isNotEmpty
                          ? 'Selected once (cannot be changed)'
                          : 'Select once — cannot be changed later',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white38 : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _hometown.isNotEmpty ? _hometown : 'Select Once',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: _hometown.isNotEmpty
                                ? (isDark ? Colors.white70 : Colors.black87)
                                : const Color(0xFFFF1493),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          _isHometownLocked && _hometown.isNotEmpty
                              ? Icons.lock_outline_rounded
                              : Icons.chevron_right_rounded,
                          color: _isHometownLocked && _hometown.isNotEmpty
                              ? Colors.amber
                              : (isDark ? Colors.white38 : Colors.grey.shade400),
                          size: 18.sp,
                        ),
                      ],
                    ),
                    onTap: _handleHometownTap,
                  ),
                  SizedBox(height: 6.h),
                ],
              ),
            ),

            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18.sp),
    );
  }

  Widget _buildCardContainer({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141624) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      leading: _buildIconCircle(icon, iconColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.darkNavy,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.grey.shade400, size: 19.sp),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 58.w,
      endIndent: 16.w,
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
    );
  }
}
