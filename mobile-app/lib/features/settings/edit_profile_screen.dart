import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/services/personal_details_service.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Edit Profile Screen matching Image 3 Reference:
/// - Header: `< Edit`
/// - Top Center: User Avatar with `[ 📷 ]` camera badge
/// - Card 1: `Bio` -> `Describe yourself... >`
/// - Card 2: `Basic information` with 8 interactive rows:
///   * Nickname
///   * Gender
///   * DOB (Date of Birth)
///   * Location
///   * Hometown
///   * Height
///   * Weight
///   * Occupation
/// - Card 3: `Personality and traits` with chips & `Edit >`
/// - Card 4: `Hobbies` with chips & `Edit >`
/// All options are 100% interactive, editable via clean modals, and saved.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _avatarPath;
  late String _nickname;
  late String _bio;
  late String _gender;
  DateTime? _dob;
  late String _location;
  late String _hometown;
  late String _height;
  late String _weight;
  late String _occupation;
  List<String> _traits = [];
  List<String> _hobbies = [];
  bool _isLoading = true;

  final List<String> _allTraits = [
    'Romantic',
    'Adventurous',
    'Fun',
    'Patient',
    'Ambitious',
    'Creative',
    'Energetic',
    'Calm',
    'Humorous',
    'Charming',
  ];

  final List<String> _allHobbies = [
    'Music 🎵',
    'Gaming 🎮',
    'Travel ✈️',
    'Fitness 🏋️',
    'Reading 📚',
    'Photography 📸',
    'Cooking 🍳',
    'Streaming 🎙️',
    'Dancing 💃',
    'Movies 🎬',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = context.read<AuthProvider>().currentUser;
    _nickname = user.name.isNotEmpty && user.name != 'Guest' ? user.name : (user.username.isNotEmpty ? user.username : 'danial');
    _bio = user.bio.isNotEmpty ? user.bio : 'Describe yourself...';
    _gender = user.gender.isNotEmpty ? user.gender : 'Male';
    _dob = user.dateOfBirth ?? DateTime(2005, 2, 15);

    final details = await PersonalDetailsService.instance.getDetails(user);
    _height = details.height;
    _weight = details.weight;
    _occupation = details.occupation;
    _location = details.location;
    _hometown = details.hometown;
    _traits = List.from(details.traits);
    _hobbies = List.from(details.hobbies);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    // Save extended personal details
    final details = UserPersonalDetails(
      height: _height,
      weight: _weight,
      occupation: _occupation,
      location: _location,
      hometown: _hometown,
      traits: _traits,
      hobbies: _hobbies,
    );
    await PersonalDetailsService.instance.saveDetails(user.id, details);

    // Save profile to AuthProvider
    await auth.updateProfile(
      name: _nickname,
      bio: _bio == 'Describe yourself...' ? '' : _bio,
      gender: _gender,
      region: '$_location, Pakistan',
      birthDate: _dob,
      avatarUrl: _avatarPath,
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() => _avatarPath = file.path);
      await _saveChanges();
    }
  }

  void _editBio() {
    final controller = TextEditingController(text: _bio == 'Describe yourself...' ? '' : _bio);
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
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              maxLines: 4,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Tell the world about yourself...',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2132) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 14.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF1493),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
              ),
              onPressed: () {
                final text = controller.text.trim();
                setState(() => _bio = text.isNotEmpty ? text : 'Describe yourself...');
                _saveChanges();
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
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2132) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 14.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF1493),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  onSave(text);
                  _saveChanges();
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
            Text('Select Gender', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            ListTile(
              leading: const Icon(Icons.male_rounded, color: Color(0xFF29B6F6)),
              title: const Text('Male'),
              trailing: _gender.toLowerCase() == 'male' ? const Icon(Icons.check, color: Color(0xFFFF1493)) : null,
              onTap: () {
                setState(() => _gender = 'Male');
                _saveChanges();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.female_rounded, color: Color(0xFFFF4081)),
              title: const Text('Female'),
              trailing: _gender.toLowerCase() == 'female' ? const Icon(Icons.check, color: Color(0xFFFF1493)) : null,
              onTap: () {
                setState(() => _gender = 'Female');
                _saveChanges();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2005, 2, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked);
      await _saveChanges();
    }
  }

  void _selectOptionSheet(String title, List<String> options, String currentVal, Function(String) onSelect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141624) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select $title', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: options.map((opt) {
                final isSelected = opt == currentVal;
                return ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF1493).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF1493) : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    onSelect(opt);
                    _saveChanges();
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _editChipsSheet(String title, List<String> allList, List<String> currentList, Function(List<String>) onSave) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tempList = List<String>.from(currentList);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141624) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit $title', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: allList.map((item) {
                    final isSelected = tempList.contains(item);
                    return FilterChip(
                      label: Text(item),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFF1493).withValues(alpha: 0.25),
                      checkmarkColor: const Color(0xFFFF1493),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFFFF1493) : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setModalState(() {
                          if (selected) {
                            tempList.add(item);
                          } else {
                            tempList.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 18.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1493),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 45.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
                  ),
                  onPressed: () {
                    onSave(tempList);
                    _saveChanges();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Choices', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDob(DateTime? date) {
    if (date == null) return '2005/Feb/15';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.year}/${months[date.month - 1]}/${date.day.toString().padLeft(2, '0')}';
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
          'Edit',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            // ── Top Center Avatar with Camera Badge ─────────────────────────
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF1493), width: 2.0),
                        image: DecorationImage(
                          image: _avatarPath != null
                              ? FileImage(File(_avatarPath!)) as ImageProvider
                              : (user.avatarUrl.isNotEmpty
                                  ? NetworkImage(user.avatarUrl)
                                  : const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80')),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2132) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Icon(Icons.camera_alt_rounded, size: 14.sp, color: const Color(0xFFFF1493)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // ── Card 1: Bio ─────────────────────────────────────────────────
            _buildCardContainer(
              isDark: isDark,
              child: _buildListRow(
                title: 'Bio',
                value: _bio,
                isDark: isDark,
                onTap: _editBio,
              ),
            ),

            SizedBox(height: 12.h),

            // ── Card 2: Basic Information ───────────────────────────────────
            _buildCardContainer(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 14.w, top: 12.h, bottom: 4.h),
                    child: Text(
                      'Basic information',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                    ),
                  ),
                  _buildListRow(
                    title: 'Nickname',
                    value: _nickname,
                    isDark: isDark,
                    onTap: () => _editTextValue('Nickname', _nickname, (v) => setState(() => _nickname = v)),
                  ),
                  _buildDivider(isDark),
                  _buildListRow(
                    title: 'Gender',
                    value: _gender,
                    isDark: isDark,
                    onTap: _selectGender,
                  ),
                  _buildDivider(isDark),
                  _buildListRow(
                    title: 'DOB',
                    value: _formatDob(_dob),
                    isDark: isDark,
                    onTap: _selectDateOfBirth,
                  ),
                  _buildDivider(isDark),
                  _buildListRow(
                    title: 'Location',
                    value: _location,
                    isDark: isDark,
                    onTap: () => _editTextValue('Location', _location, (v) => setState(() => _location = v)),
                  ),
                  _buildDivider(isDark),
                  _buildListRow(
                    title: 'Hometown',
                    value: _hometown,
                    isDark: isDark,
                    onTap: () => _editTextValue('Hometown', _hometown, (v) => setState(() => _hometown = v)),
                  ),
                  _buildDivider(isDark),
                  _buildListRow(
                    title: 'Height',
                    value: _height,
                    isDark: isDark,
                    onTap: () => _selectOptionSheet(
                      'Height',
                      ['160cm', '165cm', '170cm', '173cm', '175cm', '180cm', '185cm', '190cm'],
                      _height,
                      (v) => setState(() => _height = v),
                    ),
                  ),
                  _buildDivider(isDark),
                  _buildListRow(
                    title: 'Weight',
                    value: _weight,
                    isDark: isDark,
                    onTap: () => _selectOptionSheet(
                      'Weight',
                      ['45-50KG', '50-55KG', '55-60KG', '60-65KG', '65-70KG', '70-75KG', '75-80KG'],
                      _weight,
                      (v) => setState(() => _weight = v),
                    ),
                  ),
                  _buildDivider(isDark),
                  _buildListRow(
                    title: 'Occupation',
                    value: _occupation,
                    isDark: isDark,
                    onTap: () => _selectOptionSheet(
                      'Occupation',
                      ['Developer', 'Small Business', 'Student', 'Fashion Model', 'Digital Creator', 'Doctor', 'Freelancer'],
                      _occupation,
                      (v) => setState(() => _occupation = v),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Card 3: Personality and Traits ──────────────────────────────
            _buildCardContainer(
              isDark: isDark,
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Personality and traits',
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _editChipsSheet(
                            'Personality and Traits',
                            _allTraits,
                            _traits,
                            (newList) => setState(() => _traits = newList),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 18.sp, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _traits.map((t) => _buildChip(t, isDark)).toList(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Card 4: Hobbies ─────────────────────────────────────────────
            _buildCardContainer(
              isDark: isDark,
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hobbies',
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _editChipsSheet(
                            'Hobbies',
                            _allHobbies,
                            _hobbies,
                            (newList) => setState(() => _hobbies = newList),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 18.sp, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _hobbies.map((h) => _buildChip(h, isDark)).toList(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 35.h),
          ],
        ),
      ),
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
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildListRow({
    required String title,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
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
              fontSize: 13.sp,
              color: isDark ? Colors.white54 : Colors.grey.shade700,
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
      indent: 14.w,
      endIndent: 14.w,
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildChip(String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D2032) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}
