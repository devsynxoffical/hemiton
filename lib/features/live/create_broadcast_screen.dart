import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/room_share_service.dart';
import '../../providers/auth_provider.dart';

class CreateBroadcastScreen extends StatefulWidget {
  const CreateBroadcastScreen({super.key});

  @override
  State<CreateBroadcastScreen> createState() => _CreateBroadcastScreenState();
}

class _CreateBroadcastScreenState extends State<CreateBroadcastScreen> {
  final _titleController = TextEditingController(text: '✨ Late Night Melodies & Chill Hangout');
  final _descriptionController = TextEditingController(text: 'Join me for acoustic songs, live chat, and special party room vibes!');
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 3));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 21, minute: 0);
  String _selectedCategory = 'Music';
  bool _notifyFollowers = true;
  bool _isSaving = false;

  final List<String> _categories = [
    'Music',
    'Talk Show',
    'Late Night',
    'Gaming',
    'Dance',
    'Q&A Session',
  ];

  final List<String> _presetCovers = [
    'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=80',
    'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&q=80',
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&q=80',
    'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&q=80',
  ];
  int _selectedCoverIndex = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF1493),
              onPrimary: Colors.white,
              surface: Color(0xFF13151D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF1493),
              onPrimary: Colors.white,
              surface: Color(0xFF13151D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  void _handleSchedule() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a broadcast title'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);

    final title = _titleController.text.trim();
    final timeStr = '${_scheduledTime.format(context)} on ${_scheduledDate.day}/${_scheduledDate.month}';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13151D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        side: BorderSide(color: const Color(0xFFFF1493).withValues(alpha: 0.3)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1493), Color(0xFFFF2A9D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1493).withValues(alpha: 0.5),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            SizedBox(height: 14.h),
            Text(
              'Broadcast Scheduled! 🚀',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '"$title" is scheduled for $timeStr. Invite your friends to tune in!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13.sp),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1493),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      RoomShareService.shareText(
                        context,
                        'Join my upcoming live broadcast on HEMI TON: "$title" at $timeStr! 🔥',
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    label: const Text('Share Invite Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07080C) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF07080C) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.darkNavy, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Broadcast',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Selection Preview
            Text(
              'Broadcast Cover',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFFF1493).withValues(alpha: 0.5), width: 1.5),
                image: DecorationImage(
                  image: NetworkImage(_presetCovers[_selectedCoverIndex]),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: EdgeInsets.all(12.w),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundImage: currentUser.avatarUrl.isNotEmpty ? NetworkImage(currentUser.avatarUrl) : null,
                      child: currentUser.avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Host: ${currentUser.displayName.isNotEmpty ? currentUser.displayName : "You"}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            // Cover Selector Thumbnails
            SizedBox(
              height: 48.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presetCovers.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedCoverIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCoverIndex = i),
                    child: Container(
                      width: 64.w,
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF1493) : Colors.transparent,
                          width: 2.0,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(_presetCovers[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),

            // Title Input
            Text(
              'Broadcast Title',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _titleController,
              style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Enter title for your live broadcast...',
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: Color(0xFFFF1493), width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Category Chips
            Text(
              'Category',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF1493),
                  backgroundColor: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.darkNavy),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),

            // Date & Time Selectors
            Text(
              'Schedule Time',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: isDark ? const Color(0xFF222736) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 18.w, color: const Color(0xFFFF1493)),
                          SizedBox(width: 8.w),
                          Text(
                            '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}',
                            style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: isDark ? const Color(0xFF222736) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 18.w, color: const Color(0xFFFF1493)),
                          SizedBox(width: 8.w),
                          Text(
                            _scheduledTime.format(context),
                            style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // Notification Switch
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: const Color(0xFFFF1493), size: 20.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notify Followers', style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                        Text('Send reminder push alert before live starts', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 11.sp)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notifyFollowers,
                    activeThumbColor: const Color(0xFFFF1493),
                    onChanged: (val) => setState(() => _notifyFollowers = val),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1493),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 6,
                  shadowColor: const Color(0xFFFF1493).withValues(alpha: 0.6),
                ),
                onPressed: _isSaving ? null : _handleSchedule,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20.w),
                          SizedBox(width: 8.w),
                          Text(
                            'Schedule & Share Broadcast',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
