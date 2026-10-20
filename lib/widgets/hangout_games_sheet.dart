import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/hangout_game_model.dart';
import '../providers/auth_provider.dart';
import 'user_avatar.dart';

/// Feature 4: Interactive Hangout Games
/// In-room multiplayer interactive games (Trivia Battle & Truth or Dare Hangout)
/// with turn synchronization, real-time scoring, timers, and winner celebration splash.
class HangoutGamesSheet extends StatefulWidget {
  final String roomId;
  final String roomTitle;
  final List<HangoutGamePlayer>? initialPlayers;

  const HangoutGamesSheet({
    super.key,
    required this.roomId,
    required this.roomTitle,
    this.initialPlayers,
  });

  static Future<void> show(
    BuildContext context, {
    required String roomId,
    required String roomTitle,
    List<HangoutGamePlayer>? initialPlayers,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => HangoutGamesSheet(
        roomId: roomId,
        roomTitle: roomTitle,
        initialPlayers: initialPlayers,
      ),
    );
  }

  @override
  State<HangoutGamesSheet> createState() => _HangoutGamesSheetState();
}

class _HangoutGamesSheetState extends State<HangoutGamesSheet> {
  HangoutGameType _selectedGameType = HangoutGameType.trivia;
  late HangoutGameState _gameState;

  // Trivia State
  int _triviaQuestionIndex = 0;
  int _triviaSecondsLeft = 15;
  Timer? _triviaTimer;
  int? _userSelectedOption;
  bool _revealedAnswer = false;

  // Truth or Dare State
  TruthOrDarePrompt? _currentPrompt;
  bool _isPromptTruth = true;

  @override
  void initState() {
    super.initState();
    _initGameState();
  }

  void _initGameState() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.currentUser.id.isNotEmpty ? auth.currentUser.id : 'user_self';
    final currentUserName = auth.currentUser.name.isNotEmpty == true
        ? auth.currentUser.name
        : 'You';
    final currentUserAvatar = auth.currentUser.avatarUrl;

    final players = widget.initialPlayers ??
        [
          HangoutGamePlayer(
            userId: currentUserId,
            name: currentUserName,
            avatar: currentUserAvatar,
            score: 0,
            isCurrentTurn: true,
          ),
          HangoutGamePlayer(
            userId: 'player_alex',
            name: 'Alex R.',
            avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
            score: 0,
          ),
          HangoutGamePlayer(
            userId: 'player_maya',
            name: 'Maya S.',
            avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
            score: 0,
          ),
        ];

    _gameState = HangoutGameState(
      gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
      gameType: _selectedGameType,
      roomId: widget.roomId,
      players: players,
      totalRounds: 5,
    );

    if (_selectedGameType == HangoutGameType.trivia) {
      _startTriviaTimer();
    } else {
      _pickTruthOrDarePrompt(true);
    }
  }

  void _startTriviaTimer() {
    _triviaTimer?.cancel();
    _triviaSecondsLeft = 15;
    _userSelectedOption = null;
    _revealedAnswer = false;

    _triviaTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_triviaSecondsLeft > 0) {
        setState(() {
          _triviaSecondsLeft--;
        });
      } else {
        timer.cancel();
        _onTriviaTimeOut();
      }
    });
  }

  void _onTriviaTimeOut() {
    setState(() {
      _revealedAnswer = true;
    });
  }

  void _selectTriviaAnswer(int index) {
    if (_revealedAnswer || _userSelectedOption != null) return;
    final currentQ = HangoutTriviaQuestion.curatedTrivia[_triviaQuestionIndex %
        HangoutTriviaQuestion.curatedTrivia.length];

    setState(() {
      _userSelectedOption = index;
      _revealedAnswer = true;
      _triviaTimer?.cancel();

      if (index == currentQ.correctOptionIndex) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = auth.currentUser.id.isNotEmpty ? auth.currentUser.id : 'user_self';
        _gameState.recordAnswer(currentUserId, index, 100);
      }
    });
  }

  void _nextTriviaRound() {
    if (_gameState.currentRound >= _gameState.totalRounds) {
      setState(() {
        _gameState.isGameOver = true;
      });
      return;
    }

    setState(() {
      _triviaQuestionIndex = (_triviaQuestionIndex + 1) %
          HangoutTriviaQuestion.curatedTrivia.length;
      _gameState.nextTurn();
      _startTriviaTimer();
    });
  }

  void _pickTruthOrDarePrompt(bool isTruth) {
    setState(() {
      _isPromptTruth = isTruth;
      _currentPrompt = TruthOrDarePrompt.getRandom(isTruth: isTruth);
    });
  }

  void _passTruthOrDareTurn() {
    final currPlayer = _gameState.currentTurnPlayer;
    if (currPlayer != null) {
      currPlayer.score += 50; // Reward for completing dare/truth
    }
    if (_gameState.currentRound >= _gameState.totalRounds &&
        _gameState.currentTurnIndex == _gameState.players.length - 1) {
      setState(() {
        _gameState.isGameOver = true;
      });
      return;
    }

    setState(() {
      _gameState.nextTurn();
      _pickTruthOrDarePrompt(_isPromptTruth);
    });
  }

  @override
  void dispose() {
    _triviaTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.88.sh),
      decoration: BoxDecoration(
        color: const Color(0xFF130E24).withValues(alpha: 0.98),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag bar
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

              // Game Header & Close
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
                              colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            _selectedGameType.iconEmoji,
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedGameType.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Round ${_gameState.currentRound} of ${_gameState.totalRounds} • Live Room Play',
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
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Game Type Selector Chips
              Row(
                children: [
                  _buildTypeTab(HangoutGameType.trivia, '🧠 Trivia Battle'),
                  SizedBox(width: 8.w),
                  _buildTypeTab(HangoutGameType.truthOrDare, '🎭 Truth or Dare'),
                ],
              ),

              SizedBox(height: 14.h),

              // Player Score Strip
              _buildPlayersScoreStrip(),

              SizedBox(height: 14.h),

              // Game Play Area or Winner Splash
              Expanded(
                child: _gameState.isGameOver
                    ? _buildWinnerCelebrationSplash()
                    : _selectedGameType == HangoutGameType.trivia
                        ? _buildTriviaBattleView()
                        : _buildTruthOrDareView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(HangoutGameType type, String label) {
    final isSelected = _selectedGameType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedGameType == type) return;
          setState(() {
            _selectedGameType = type;
            _gameState = HangoutGameState(
              gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
              gameType: type,
              roomId: widget.roomId,
              players: _gameState.players,
              totalRounds: 5,
            );
          });
          if (type == HangoutGameType.trivia) {
            _startTriviaTimer();
          } else {
            _pickTruthOrDarePrompt(true);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
                  )
                : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12.5.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersScoreStrip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _gameState.players.map((player) {
          final isTurn = player.isCurrentTurn;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isTurn ? const Color(0xFF00F5D4) : Colors.transparent,
                    width: 2.2,
                  ),
                ),
                child: UserAvatar(
                  imageUrl: player.avatar,
                  radius: 17.r,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                player.name,
                style: TextStyle(
                  color: isTurn ? const Color(0xFF00F5D4) : Colors.white70,
                  fontSize: 10.sp,
                  fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${player.score} pts',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTriviaBattleView() {
    final question = HangoutTriviaQuestion.curatedTrivia[
        _triviaQuestionIndex % HangoutTriviaQuestion.curatedTrivia.length];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Timer bar & Question
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_rounded,
                      color: _triviaSecondsLeft <= 5
                          ? Colors.redAccent
                          : const Color(0xFF00F5D4),
                      size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    '$_triviaSecondsLeft s',
                    style: TextStyle(
                      color: _triviaSecondsLeft <= 5
                          ? Colors.redAccent
                          : const Color(0xFF00F5D4),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              Text(
                'Correct: +100 pts',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          LinearProgressIndicator(
            value: _triviaSecondsLeft / 15.0,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _triviaSecondsLeft <= 5
                  ? Colors.redAccent
                  : const Color(0xFF00F5D4),
            ),
            minHeight: 4.h,
            borderRadius: BorderRadius.circular(2.r),
          ),

          SizedBox(height: 12.h),

          // Question Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              question.question,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5.sp,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Options Grid
          ...List.generate(question.options.length, (idx) {
            final optionText = question.options[idx];
            final isSelected = _userSelectedOption == idx;
            final isCorrect = idx == question.correctOptionIndex;

            Color optionBg = Colors.white.withValues(alpha: 0.08);
            Color borderColor = Colors.white.withValues(alpha: 0.15);

            if (_revealedAnswer) {
              if (isCorrect) {
                optionBg = const Color(0xFF16A34A).withValues(alpha: 0.35);
                borderColor = const Color(0xFF22C55E);
              } else if (isSelected) {
                optionBg = Colors.red.withValues(alpha: 0.35);
                borderColor = Colors.redAccent;
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: GestureDetector(
                onTap: () => _selectTriviaAnswer(idx),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: optionBg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + idx),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_revealedAnswer && isCorrect)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF22C55E),
                          size: 18,
                        ),
                      if (_revealedAnswer && isSelected && !isCorrect)
                        const Icon(
                          Icons.cancel_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          if (_revealedAnswer) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '💡 ${question.funFact}',
                style: TextStyle(
                  color: Colors.indigoAccent,
                  fontSize: 11.5.sp,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: _nextTriviaRound,
              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              label: Text(
                _gameState.currentRound >= _gameState.totalRounds
                    ? 'View Final Results 🏆'
                    : 'Next Round ➡️',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                minimumSize: Size(double.infinity, 42.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTruthOrDareView() {
    final currPlayer = _gameState.currentTurnPlayer;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Current Turn Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00F5D4).withValues(alpha: 0.2),
                  const Color(0xFF7928CA).withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFF00F5D4).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFF00F5D4), size: 18),
                SizedBox(width: 6.w),
                Text(
                  '${currPlayer?.name ?? "Player"}\'s Turn to Play!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Truth vs Dare choice buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pickTruthOrDarePrompt(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPromptTruth
                        ? const Color(0xFF00F5D4)
                        : Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    '😇 Truth',
                    style: TextStyle(
                      color: _isPromptTruth ? Colors.black87 : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pickTruthOrDarePrompt(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isPromptTruth
                        ? const Color(0xFFFF007A)
                        : Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    '😈 Dare',
                    style: TextStyle(
                      color: !_isPromptTruth ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Prompt Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: _isPromptTruth
                    ? const Color(0xFF00F5D4).withValues(alpha: 0.3)
                    : const Color(0xFFFF007A).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _isPromptTruth ? 'THE TRUTH QUESTION' : 'THE DARE CHALLENGE',
                  style: TextStyle(
                    color: _isPromptTruth
                        ? const Color(0xFF00F5D4)
                        : const Color(0xFFFF007A),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  _currentPrompt?.prompt ?? 'Spinning prompt...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Action Buttons: Done / Pass Turn
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTruthOrDarePrompt(_isPromptTruth),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                  child: Text(
                    '🔄 Re-Roll',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _passTruthOrDareTurn,
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    'Completed (+50 pts) ➡️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCelebrationSplash() {
    final leader = _gameState.leadingPlayer;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '🎉 GAME OVER! 🎉',
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Winner: ${leader?.name ?? "Champion"} with ${leader?.score ?? 0} pts!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '+150 Social Hangout XP Awarded! 🌟',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11.5.sp,
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initGameState();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 10.h,
                ),
              ),
              child: Text(
                'Play Again 🎮',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
