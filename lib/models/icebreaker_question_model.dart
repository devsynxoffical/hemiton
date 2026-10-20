import 'dart:math';

/// Category of icebreaker questions
enum IcebreakerCategory {
  all,
  fun,
  deep,
  spicy,
  wouldYouRather,
  lighthearted,
}

extension IcebreakerCategoryX on IcebreakerCategory {
  String get label {
    switch (this) {
      case IcebreakerCategory.all:
        return 'All Topics';
      case IcebreakerCategory.fun:
        return '🎉 Fun & Crazy';
      case IcebreakerCategory.deep:
        return '🌊 Deep & Real';
      case IcebreakerCategory.spicy:
        return '🌶️ Spicy & Bold';
      case IcebreakerCategory.wouldYouRather:
        return '⚖️ Would You Rather';
      case IcebreakerCategory.lighthearted:
        return '✨ Chill Vibes';
    }
  }

  String get shortLabel {
    switch (this) {
      case IcebreakerCategory.all:
        return 'All';
      case IcebreakerCategory.fun:
        return 'Fun';
      case IcebreakerCategory.deep:
        return 'Deep';
      case IcebreakerCategory.spicy:
        return 'Spicy';
      case IcebreakerCategory.wouldYouRather:
        return 'Would You Rather';
      case IcebreakerCategory.lighthearted:
        return 'Chill';
    }
  }
}

/// Represents a single icebreaker prompt
class IcebreakerQuestionModel {
  final String id;
  final String question;
  final IcebreakerCategory category;
  final String? hint;

  const IcebreakerQuestionModel({
    required this.id,
    required this.question,
    required this.category,
    this.hint,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'category': category.name,
        'hint': hint,
      };

  factory IcebreakerQuestionModel.fromJson(Map<String, dynamic> json) {
    final catName = json['category']?.toString();
    final cat = IcebreakerCategory.values.firstWhere(
      (e) => e.name == catName,
      orElse: () => IcebreakerCategory.fun,
    );
    return IcebreakerQuestionModel(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      category: cat,
      hint: json['hint']?.toString(),
    );
  }

  /// Curated built-in icebreaker prompts for instant, zero-latency room engagement
  static const List<IcebreakerQuestionModel> defaultQuestions = [
    // Fun & Crazy
    IcebreakerQuestionModel(
      id: 'ib_f_1',
      category: IcebreakerCategory.fun,
      question: 'What is the most ridiculous lie you believed as a child?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_f_2',
      category: IcebreakerCategory.fun,
      question: 'If you had to enter a karaoke contest right now with zero prep, what song are you singing?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_f_3',
      category: IcebreakerCategory.fun,
      question: 'What is your most useless secret talent?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_f_4',
      category: IcebreakerCategory.fun,
      question: 'If you were turned into a food, what would you be and why?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_f_5',
      category: IcebreakerCategory.fun,
      question: 'What is the weirdest app you have installed on your phone right now?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_f_6',
      category: IcebreakerCategory.fun,
      question: 'What is the funniest thing that has ever happened to you in an online meeting or stream?',
    ),

    // Deep & Real
    IcebreakerQuestionModel(
      id: 'ib_d_1',
      category: IcebreakerCategory.deep,
      question: 'What is a life lesson you had to learn the hard way?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_d_2',
      category: IcebreakerCategory.deep,
      question: 'What is one quality you value most in a true friend?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_d_3',
      category: IcebreakerCategory.deep,
      question: 'If you could give your 16-year-old self 30 seconds of advice, what would you say?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_d_4',
      category: IcebreakerCategory.deep,
      question: 'What is something that instantly makes you respect someone?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_d_5',
      category: IcebreakerCategory.deep,
      question: 'What dream are you actively working toward right now?',
    ),

    // Spicy & Bold
    IcebreakerQuestionModel(
      id: 'ib_s_1',
      category: IcebreakerCategory.spicy,
      question: 'What is your most controversial food or music opinion that you will defend to the death?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_s_2',
      category: IcebreakerCategory.spicy,
      question: 'Have you ever ghosted someone, and did they deserve it?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_s_3',
      category: IcebreakerCategory.spicy,
      question: 'What is an immediate red flag and an immediate green flag on a first date?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_s_4',
      category: IcebreakerCategory.spicy,
      question: 'What is a popular trend that you secretly think is totally overrated?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_s_5',
      category: IcebreakerCategory.spicy,
      question: 'Who in your contacts would you call if you were in jail at 3 AM?',
    ),

    // Would You Rather
    IcebreakerQuestionModel(
      id: 'ib_w_1',
      category: IcebreakerCategory.wouldYouRather,
      question: 'Would you rather speak all world languages fluently or be able to talk to animals?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_w_2',
      category: IcebreakerCategory.wouldYouRather,
      question: 'Would you rather always have 100% phone battery or unlimited high-speed internet anywhere on Earth?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_w_3',
      category: IcebreakerCategory.wouldYouRather,
      question: 'Would you rather never have to sleep again or never have to eat again (with zero health downsides)?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_w_4',
      category: IcebreakerCategory.wouldYouRather,
      question: 'Would you rather travel 100 years into the past or 100 years into the future?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_w_5',
      category: IcebreakerCategory.wouldYouRather,
      question: 'Would you rather be famous for something silly or unknown but change the world secretly?',
    ),

    // Chill Vibes
    IcebreakerQuestionModel(
      id: 'ib_c_1',
      category: IcebreakerCategory.lighthearted,
      question: 'What is your ultimate comfort food after a tiring day?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_c_2',
      category: IcebreakerCategory.lighthearted,
      question: 'What is the best movie or series you have watched recently?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_c_3',
      category: IcebreakerCategory.lighthearted,
      question: 'If you could teleport to any place in the world right now for 1 hour, where are you going?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_c_4',
      category: IcebreakerCategory.lighthearted,
      question: 'What is the last song you had on repeat?',
    ),
    IcebreakerQuestionModel(
      id: 'ib_c_5',
      category: IcebreakerCategory.lighthearted,
      question: 'Morning person or night owl? What is your prime creative hour?',
    ),
  ];

  /// Get a random question, optionally filtered by category
  static IcebreakerQuestionModel getRandom({
    IcebreakerCategory category = IcebreakerCategory.all,
    String? excludeId,
    Random? random,
  }) {
    final rng = random ?? Random();
    List<IcebreakerQuestionModel> pool;
    if (category == IcebreakerCategory.all) {
      pool = defaultQuestions;
    } else {
      pool = defaultQuestions.where((q) => q.category == category).toList();
    }

    if (pool.isEmpty) pool = defaultQuestions;

    if (excludeId != null && pool.length > 1) {
      final filtered = pool.where((q) => q.id != excludeId).toList();
      if (filtered.isNotEmpty) pool = filtered;
    }

    return pool[rng.nextInt(pool.length)];
  }
}
