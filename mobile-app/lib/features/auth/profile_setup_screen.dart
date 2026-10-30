import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/personal_details_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/animations/app_animations.dart';
import '../../widgets/design/gold_button.dart';
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
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Profile Picture & Bio
  String? _selectedImagePath;
  final _bioController = TextEditingController();

  // Step 2: Nickname & Username
  final _nicknameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  String? _usernameStatusText;

  // Step 3: Gender & Date of Birth
  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female'];
  DateTime? _selectedDob;

  // Step 4: Location (According to current location) & Hometown (One-time selection)
  String _location = 'Islamabad, Pakistan';
  bool _isDetectingLocation = false;
  String _selectedHometown = '';
  final _customHometownController = TextEditingController();

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
    _checkUsername(currentUser.username);
    _autoDetectLocation();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nicknameController.dispose();
    _usernameController.dispose();
    _customHometownController.dispose();
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
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _checkUsername(String username) async {
    if (username.trim().length < 3) {
      setState(() {
        _isUsernameAvailable = false;
        _usernameStatusText = 'Username must be at least 3 characters';
      });
      return;
    }
    setState(() {
      _isCheckingUsername = true;
      _usernameStatusText = 'Checking availability...';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final available = await authProvider.checkUsernameAvailable(username);

    if (mounted) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = available;
        _usernameStatusText = available ? 'Username available!' : 'Username already taken';
      });
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 20, now.month, now.day);
    final firstDate = DateTime(1950);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
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
    if (_location.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please detect your current Location')),
      );
      return;
    }
    if (_selectedHometown.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your Hometown (Required to complete account creation)'),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final calculatedAge = _calculateAge(_selectedDob!);

    // Save Location & Permanently Lock One-Time Hometown Selection
    await PersonalDetailsService.instance.saveDetails(
      authProvider.currentUser.id,
      UserPersonalDetails(
        location: _location.trim(),
        hometown: _selectedHometown.trim(),
        isHometownLocked: true,
      ),
    );

    final bioText = _bioController.text.trim().isNotEmpty
        ? _bioController.text.trim()
        : 'Hey there! I am streaming on HEMI TON ✨';

    final success = await authProvider.completeProfileOnboarding(
      name: _nicknameController.text.trim(),
      username: _usernameController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDob!,
      region: _location.trim(),
      bio: bioText,
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

  void _nextStep() {
    if (_currentStep == 0) {
      if (_bioController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a short Bio to continue')),
        );
        return;
      }
    } else if (_currentStep == 1) {
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
    } else if (_currentStep == 2) {
      if (_selectedDob == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your Date of Birth')),
        );
        return;
      }
    } else if (_currentStep == 3) {
      if (_selectedHometown.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your Hometown to complete your account')),
        );
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finishProfileSetup();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentStep > 0) {
          _prevStep();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete all profile steps to create your account.'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.getBackground(isDark),
        appBar: AppBar(
          title: const Text('Complete Profile'),
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: _prevStep,
                )
              : null,
          actions: [
            TextButton(
              onPressed: _cancelAndAbortAccount,
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.liveRed, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Progress Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalSteps, (index) {
                    final isActive = index <= _currentStep;
                    return AnimatedContainer(
                      duration: AppAnimations.normal,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 28 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.getPrimary(isDark)
                            : AppColors.getBorder(isDark),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps — Required to create account',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 18),

                // Step Content Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_currentStep == 0) _buildProfilePictureAndBioStep(isDark),
                        if (_currentStep == 1) _buildNicknameAndUsernameStep(isDark),
                        if (_currentStep == 2) _buildGenderAndDobStep(isDark),
                        if (_currentStep == 3) _buildLocationAndHometownStep(isDark),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation CTA Button
                GoldButton(
                  text: _currentStep == _totalSteps - 1
                      ? 'COMPLETE PROFILE & CREATE ACCOUNT'
                      : 'CONTINUE',
                  onPressed: _nextStep,
                  isLoading: authProvider.isLoading,
                  height: 52,
                  radius: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // STEP 1: PROFILE PICTURE & BIO
  Widget _buildProfilePictureAndBioStep(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'Profile Picture & Bio',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Add your photo and write a bio so others can know you',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: 24),

        // Avatar Preview with Metallic/Gold Ring
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.getAccentGradient(isDark),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getPrimary(isDark).withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.getCard(isDark),
                backgroundImage: _selectedImagePath != null
                    ? FileImage(File(_selectedImagePath!)) as ImageProvider
                    : null,
                child: _selectedImagePath == null
                    ? Icon(Icons.person_rounded, size: 56, color: AppColors.getPrimary(isDark))
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.getPrimary(isDark),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.getCard(isDark), width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.onGold(isDark: isDark),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_rounded),
              label: const Text('Camera'),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Gallery'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Bio Input
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Your Bio *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          maxLines: 3,
          maxLength: 150,
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
          decoration: InputDecoration(
            hintText: 'Write a short bio about yourself...',
            filled: true,
            fillColor: AppColors.getSurface(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: NICKNAME & USERNAME
  Widget _buildNicknameAndUsernameStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Nickname & Username',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Set your display name and unique handle across live rooms',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ),
        const SizedBox(height: 28),

        Text(
          'Nickname *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getBorder(isDark), width: 1.2),
          ),
          child: TextField(
            controller: _nicknameController,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: const InputDecoration(
              hintText: 'Enter your display nickname',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Username *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isUsernameAvailable == true
                  ? AppColors.success
                  : (_isUsernameAvailable == false ? AppColors.liveRed : AppColors.getBorder(isDark)),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: _usernameController,
            onChanged: (val) => _checkUsername(val),
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: 'Enter username',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              suffixIcon: _isCheckingUsername
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_isUsernameAvailable == true
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                      : (_isUsernameAvailable == false
                          ? const Icon(Icons.cancel_rounded, color: AppColors.liveRed)
                          : null)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_usernameStatusText != null)
          AnimatedDefaultTextStyle(
            duration: AppAnimations.fast,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isUsernameAvailable == true
                  ? AppColors.success
                  : (_isUsernameAvailable == false ? AppColors.liveRed : AppColors.getTextSecondary(isDark)),
            ),
            child: Text(_usernameStatusText!),
          ),
      ],
    );
  }

  // STEP 3: GENDER & DATE OF BIRTH
  Widget _buildGenderAndDobStep(bool isDark) {
    final int? calculatedAge = _selectedDob != null ? _calculateAge(_selectedDob!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Gender & Date of Birth',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Required for live permissions and age verification',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ),
        const SizedBox(height: 22),

        Text(
          'Select Gender *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _genderOptions.map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  margin: EdgeInsets.only(right: gender == 'Male' ? 8 : 0, left: gender == 'Female' ? 8 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.getPrimary(isDark).withValues(alpha: 0.14)
                        : AppColors.getCard(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.getPrimary(isDark)
                          : AppColors.getBorder(isDark),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gender == 'Female' ? Icons.female_rounded : Icons.male_rounded,
                        color: gender == 'Female' ? const Color(0xFFFF4081) : const Color(0xFF29B6F6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        gender,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.getPrimary(isDark)
                              : AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        Text(
          'Date of Birth *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _selectDateOfBirth(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.getCard(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.getPrimary(isDark),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      _selectedDob != null
                          ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
                          : 'Select your birth date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedDob != null
                            ? AppColors.getTextPrimary(isDark)
                            : AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_drop_down_rounded, color: AppColors.getTextSecondary(isDark)),
              ],
            ),
          ),
        ),

        if (calculatedAge != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: calculatedAge >= 18
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.liveRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: calculatedAge >= 18 ? AppColors.success : AppColors.liveRed,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  calculatedAge >= 18 ? Icons.verified_user_rounded : Icons.info_outline_rounded,
                  color: calculatedAge >= 18 ? AppColors.success : AppColors.liveRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Calculated Age: $calculatedAge years old',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: calculatedAge >= 18 ? AppColors.success : AppColors.liveRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // STEP 4: LOCATION (AUTO-DETECTED) & HOMETOWN (ONE-TIME SELECTION)
  Widget _buildLocationAndHometownStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Location & Hometown',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Your location is detected automatically. Hometown can only be selected once!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // 1. Current Location (According to your location)
        Text(
          'Current Location (Auto-Detected) *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.getCard(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.my_location_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _location,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Detected according to your current location',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _autoDetectLocation,
                icon: _isDetectingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, color: AppColors.success),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // 2. Hometown (One-Time Selection Only — Cannot Be Changed Later)
        Row(
          children: [
            Text(
              'Select Hometown (One-Time Only) *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.lock_clock_rounded, size: 16, color: Colors.amber),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Important: Hometown can only be selected once and cannot be changed later.',
                  style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customHometownController,
          onChanged: (val) {
            if (val.trim().isNotEmpty) {
              setState(() => _selectedHometown = val.trim());
            }
          },
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
          decoration: InputDecoration(
            hintText: 'Type or choose your hometown city below...',
            prefixIcon: const Icon(Icons.home_work_rounded),
            filled: true,
            fillColor: AppColors.getSurface(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularHometowns.map((city) {
            final isSelected = _selectedHometown == city;
            return ChoiceChip(
              label: Text(city),
              selected: isSelected,
              selectedColor: AppColors.getPrimary(isDark).withValues(alpha: 0.22),
              labelStyle: TextStyle(
                fontSize: 12.5,
                color: isSelected
                    ? AppColors.getPrimary(isDark)
                    : AppColors.getTextPrimary(isDark),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) {
                _customHometownController.text = city;
                setState(() => _selectedHometown = city);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
