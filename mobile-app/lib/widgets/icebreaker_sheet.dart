import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../models/icebreaker_question_model.dart';

/// Feature 3: 60-Second Icebreaker
/// In-room interactive conversation starter with a 60-second countdown timer,
/// curated category prompts, turn passing, and auto-dismiss/refresh capabilities.
class IcebreakerSheet extends StatefulWidget {
  final String roomId;
  final String? currentSpeakerName;
  final VoidCallback? onTurnPassed;

  const IcebreakerSheet({
    super.key,
    required this.roomId,
    this.currentSpeakerName,
    this.onTurnPassed,
  });

  static Future<void> show(
    BuildContext context, {
    required String roomId,
    String? currentSpeakerName,
    VoidCallback? onTurnPassed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => IcebreakerSheet(
        roomId: roomId,
        currentSpeakerName: currentSpeakerName,
        onTurnPassed: onTurnPassed,
      ),
    );
  }

  @override
  State<IcebreakerSheet> createState() => _IcebreakerSheetState();
}

class _IcebreakerSheetState extends State<IcebreakerSheet>
    with SingleTickerProviderStateMixin {
  static const int kInitialDuration = 60;

  late IcebreakerCategory _selectedCategory;
  late IcebreakerQuestionModel _currentQuestion;
  int _secondsLeft = kInitialDuration;
  bool _isRunning = true;
  Timer? _countdownTimer;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCategory = IcebreakerCategory.all;
    _currentQuestion = IcebreakerQuestionModel.getRandom(
      category: _selectedCategory,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _isRunning = true;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        _onTimerExpired();
      }
    });
  }

  void _pauseResumeTimer() {
    setState(() {
      if (_isRunning) {
        _countdownTimer?.cancel();
        _isRunning = false;
      } else {
        _startTimer();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _secondsLeft = kInitialDuration;
    });
    _startTimer();
  }

  void _onTimerExpired() {
    setState(() {
      _isRunning = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.timer_off_rounded, color: Colors.amberAccent, size: 20),
            SizedBox(width: 8),
            Text('⏰ 60 seconds are up! Ready for the next prompt?'),
          ],
        ),
        backgroundColor: Color(0xFF2D154D),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shuffleNextQuestion() {
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentQuestion = IcebreakerQuestionModel.getRandom(
          category: _selectedCategory,
          excludeId: _currentQuestion.id,
        );
        _secondsLeft = kInitialDuration;
      });
      _fadeController.forward();
      _startTimer();
    });
  }

  void _onCategorySelected(IcebreakerCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _currentQuestion = IcebreakerQuestionModel.getRandom(
        category: category,
        excludeId: _currentQuestion.id,
      );
      _secondsLeft = kInitialDuration;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _secondsLeft / kInitialDuration;
    final isLowTime = _secondsLeft <= 10;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161226).withValues(alpha: 0.96),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag pill
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Header Row: Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8C00), Color(0xFFFF007A)],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.psychology_alt_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '60-Second Icebreaker',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.currentSpeakerName != null
                                    ? 'Speaker: ${widget.currentSpeakerName}'
                                    : 'Spark the conversation • Break the silence',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // Category Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: IcebreakerCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () => _onCategorySelected(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFFF007A),
                                      Color(0xFF7928CA),
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            cat.shortLabel,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.75),
                              fontSize: 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 16.h),

              // Center Display: 60s Circular Countdown Timer & Prompt Card
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Countdown Timer Dial
                  GestureDetector(
                    onTap: _pauseResumeTimer,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 58.w,
                          height: 58.w,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4.5.w,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isLowTime
                                  ? const Color(0xFFFF3366)
                                  : const Color(0xFF00F5D4),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_secondsLeft',
                              style: TextStyle(
                                color: isLowTime
                                    ? const Color(0xFFFF3366)
                                    : Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              _isRunning ? 'sec' : 'paused',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 14.w),

                  // Prompt Card
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentQuestion.category.label,
                              style: TextStyle(
                                color: const Color(0xFFFF8C00),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _currentQuestion.question,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Action Buttons Row
              Row(
                children: [
                  // Reset 60s
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetTimer,
                      icon: Icon(
                        Icons.replay_rounded,
                        size: 16.sp,
                        color: Colors.white70,
                      ),
                      label: Text(
                        'Reset 60s',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // Next Prompt (Shuffle)
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _shuffleNextQuestion,
                      icon: Icon(
                        Icons.shuffle_rounded,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Next Prompt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
