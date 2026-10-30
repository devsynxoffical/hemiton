import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class FeedbackContactScreen extends StatefulWidget {
  const FeedbackContactScreen({super.key});

  @override
  State<FeedbackContactScreen> createState() => _FeedbackContactScreenState();
}

class _FeedbackContactScreenState extends State<FeedbackContactScreen> {
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int _selectedCategoryIndex = 0;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Suggestion',
    'Bug Report',
    'Live Room Issue',
    'Account & Security',
    'Recharge / Coins',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _emailController.text = auth.currentUser.email?.isNotEmpty == true
        ? auth.currentUser.email!
        : 'danialamjad36@gmail.com';
  }

  @override
  void dispose() {
    _msgController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write your feedback or describe the issue.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF161824)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFFF1493)),
            SizedBox(width: 8.w),
            const Text('Feedback Received', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Thank you for reaching out! Our support team will review your report and respond to your email within 24 hours.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1493),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Contact Us / Feedback',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Section Title
            Text(
              'Select Feedback Category',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
            SizedBox(height: 10.h),

            // Category Chips
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(_categories.length, (index) {
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? const Color(0xFF161826) : Colors.white),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                    ),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.black
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 20.h),

            // Message Title
            Text(
              'Your Message or Report',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
            SizedBox(height: 8.h),

            // Textarea
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141624) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: TextField(
                controller: _msgController,
                maxLines: 6,
                maxLength: 500,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 13.5.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe your feedback or problem in detail...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                    fontSize: 13.sp,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // Contact Email Field
            Text(
              'Contact Email',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141624) : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: TextField(
                controller: _emailController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 13.5.sp,
                ),
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.email_outlined,
                    color: const Color(0xFF00B0FF),
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  hintText: 'Enter your email address',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // Submit Button
            GestureDetector(
              onTap: _isSubmitting ? null : _submitFeedback,
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1493), Color(0xFF7928CA)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Text(
                        'Submit Feedback',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
