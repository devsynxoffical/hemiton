import 'dart:math';

/// Types of interactive hangout games playable in-room
enum HangoutGameType {
  trivia,
  truthOrDare,
  quickPoll,
}

extension HangoutGameTypeX on HangoutGameType {
  String get title {
    switch (this) {
      case HangoutGameType.trivia:
        return 'Hangout Trivia Battle';
      case HangoutGameType.truthOrDare:
        return 'Truth or Dare Hangout';
      case HangoutGameType.quickPoll:
        return 'Room Quick Poll';
    }
  }

  String get iconEmoji {
    switch (this) {
      case HangoutGameType.trivia:
        return '🧠';
      case HangoutGameType.truthOrDare:
        return '🎭';
      case HangoutGameType.quickPoll:
        return '📊';
    }
  }
}

/// A participant in the hangout multiplayer game
class HangoutGamePlayer {
  final String userId;
  final String name;
  final String avatar;
  int score;
  bool isCurrentTurn;
  int? selectedAnswerIndex;

  HangoutGamePlayer({
    required this.userId,
    required this.name,
    required this.avatar,
    this.score = 0,
    this.isCurrentTurn = false,
    this.selectedAnswerIndex,
  });

  HangoutGamePlayer copyWith({
    String? userId,
    String? name,
    String? avatar,
    int? score,
    bool? isCurrentTurn,
    int? selectedAnswerIndex,
  }) {
    return HangoutGamePlayer(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      score: score ?? this.score,
      isCurrentTurn: isCurrentTurn ?? this.isCurrentTurn,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'avatar': avatar,
        'score': score,
        'isCurrentTurn': isCurrentTurn,
        'selectedAnswerIndex': selectedAnswerIndex,
      };

  factory HangoutGamePlayer.fromJson(Map<String, dynamic> json) {
    return HangoutGamePlayer(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Player',
      avatar: json['avatar']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      isCurrentTurn: json['isCurrentTurn'] == true,
      selectedAnswerIndex: (json['selectedAnswerIndex'] as num?)?.toInt(),
    );
  }
}

/// A trivia question with options and correct answer
class HangoutTriviaQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String funFact;

  const HangoutTriviaQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.funFact,
  });

  static const List<HangoutTriviaQuestion> curatedTrivia = [
    HangoutTriviaQuestion(
      id: 't_1',
      question: 'Which planet in our solar system has the most moons?',
      options: ['Jupiter', 'Saturn', 'Neptune', 'Mars'],
      correctOptionIndex: 1,
      funFact: 'Saturn has over 140 officially recognized moons!',
    ),
    HangoutTriviaQuestion(
      id: 't_2',
      question: 'What is the fastest land animal in the world?',
      options: ['Lion', 'Cheetah', 'Pronghorn Antelope', 'Greyhound'],
      correctOptionIndex: 1,
      funFact: 'Cheetahs can accelerate from 0 to 60 mph in under 3 seconds.',
    ),
    HangoutTriviaQuestion(
      id: 't_3',
      question: 'Which music video was the first ever to hit 1 billion views on YouTube?',
      options: ['Despacito', 'Baby (Justin Bieber)', 'Gangnam Style', 'Shape of You'],
      correctOptionIndex: 2,
      funFact: 'PSY’s Gangnam Style broke YouTube’s 32-bit integer counter in 2012!',
    ),
    HangoutTriviaQuestion(
      id: 't_4',
      question: 'How many hearts does an octopus have?',
      options: ['1', '2', '3', '4'],
      correctOptionIndex: 2,
      funFact: 'Two hearts pump blood to the gills, while one pumps it to the rest of the body.',
    ),
    HangoutTriviaQuestion(
      id: 't_5',
      question: 'Which continent has the largest desert in the world?',
      options: ['Africa (Sahara)', 'Antarctica', 'Asia (Gobi)', 'Australia'],
      correctOptionIndex: 1,
      funFact: 'Antarctica is classified as a polar desert and is the largest on Earth!',
    ),
    HangoutTriviaQuestion(
      id: 't_6',
      question: 'What is the highest-grossing film of all time (unadjusted for inflation)?',
      options: ['Avengers: Endgame', 'Avatar', 'Titanic', 'Star Wars: The Force Awakens'],
      correctOptionIndex: 1,
      funFact: 'Avatar grossed over \$2.9 billion globally.',
    ),
  ];
}

/// A Truth or Dare prompt
class TruthOrDarePrompt {
  final String id;
  final String prompt;
  final bool isTruth;

  const TruthOrDarePrompt({
    required this.id,
    required this.prompt,
    required this.isTruth,
  });

  static const List<TruthOrDarePrompt> curatedPrompts = [
    TruthOrDarePrompt(
      id: 'tod_t_1',
      isTruth: true,
      prompt: 'What was your most embarrassing moment in high school or college?',
    ),
    TruthOrDarePrompt(
      id: 'tod_t_2',
      isTruth: true,
      prompt: 'If you had to trade lives with someone in this room for a week, who would it be?',
    ),
    TruthOrDarePrompt(
      id: 'tod_t_3',
      isTruth: true,
      prompt: 'What is a secret talent or weird hobby nobody in your family knows about?',
    ),
    TruthOrDarePrompt(
      id: 'tod_d_1',
      isTruth: false,
      prompt: 'Sing the chorus of your favorite song right now in the room microphone!',
    ),
    TruthOrDarePrompt(
      id: 'tod_d_2',
      isTruth: false,
      prompt: 'Speak in an accent of the room’s choice for the next 2 minutes.',
    ),
    TruthOrDarePrompt(
      id: 'tod_d_3',
      isTruth: false,
      prompt: 'Tell your best or worst dad joke in a dramatic movie trailer voice.',
    ),
  ];

  static TruthOrDarePrompt getRandom({required bool isTruth, Random? random}) {
    final rng = random ?? Random();
    final list = curatedPrompts.where((p) => p.isTruth == isTruth).toList();
    return list[rng.nextInt(list.length)];
  }
}

/// Overall Hangout Multiplayer Game State
class HangoutGameState {
  final String gameId;
  final HangoutGameType gameType;
  final String roomId;
  int currentRound;
  final int totalRounds;
  int timeRemaining;
  final List<HangoutGamePlayer> players;
  int currentTurnIndex;
  bool isRoundOver;
  bool isGameOver;

  HangoutGameState({
    required this.gameId,
    required this.gameType,
    required this.roomId,
    this.currentRound = 1,
    this.totalRounds = 5,
    this.timeRemaining = 15,
    required this.players,
    this.currentTurnIndex = 0,
    this.isRoundOver = false,
    this.isGameOver = false,
  });

  HangoutGamePlayer? get currentTurnPlayer {
    if (players.isEmpty || currentTurnIndex >= players.length) return null;
    return players[currentTurnIndex];
  }

  HangoutGamePlayer? get leadingPlayer {
    if (players.isEmpty) return null;
    final sorted = List<HangoutGamePlayer>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted.first;
  }

  void nextTurn() {
    if (players.isEmpty) return;
    for (final p in players) {
      p.isCurrentTurn = false;
      p.selectedAnswerIndex = null;
    }
    currentTurnIndex = (currentTurnIndex + 1) % players.length;
    players[currentTurnIndex].isCurrentTurn = true;
    if (currentTurnIndex == 0) {
      currentRound++;
      if (currentRound > totalRounds) {
        isGameOver = true;
      }
    }
  }

  void recordAnswer(String userId, int answerIndex, int points) {
    final player = players.firstWhere(
      (p) => p.userId == userId,
      orElse: () => players.first,
    );
    player.selectedAnswerIndex = answerIndex;
    player.score += points;
  }
}
