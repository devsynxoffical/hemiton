import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/icebreaker_question_model.dart';
import 'package:hemiton/widgets/icebreaker_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 3: 60-Second Icebreaker Tests', () {
    test('IcebreakerQuestionModel serialization and deserialization', () {
      final json = {
        'id': 'test_ib_1',
        'question': 'What superpower would you choose for 24 hours?',
        'category': 'fun',
        'hint': 'Be creative!',
      };

      final model = IcebreakerQuestionModel.fromJson(json);
      expect(model.id, equals('test_ib_1'));
      expect(model.question, equals('What superpower would you choose for 24 hours?'));
      expect(model.category, equals(IcebreakerCategory.fun));
      expect(model.hint, equals('Be creative!'));

      final serialized = model.toJson();
      expect(serialized['id'], equals('test_ib_1'));
      expect(serialized['category'], equals('fun'));
    });

    test('Icebreaker default questions exist for all supported categories', () {
      expect(IcebreakerQuestionModel.defaultQuestions.isNotEmpty, isTrue);

      final categoriesPresent = IcebreakerQuestionModel.defaultQuestions
          .map((q) => q.category)
          .toSet();

      expect(categoriesPresent.contains(IcebreakerCategory.fun), isTrue);
      expect(categoriesPresent.contains(IcebreakerCategory.deep), isTrue);
      expect(categoriesPresent.contains(IcebreakerCategory.spicy), isTrue);
      expect(categoriesPresent.contains(IcebreakerCategory.wouldYouRather), isTrue);
      expect(categoriesPresent.contains(IcebreakerCategory.lighthearted), isTrue);
    });

    test('getRandom returns category-filtered question and excludes previous ID', () {
      final q1 = IcebreakerQuestionModel.getRandom(
        category: IcebreakerCategory.deep,
        random: Random(42),
      );
      expect(q1.category, equals(IcebreakerCategory.deep));

      final q2 = IcebreakerQuestionModel.getRandom(
        category: IcebreakerCategory.deep,
        excludeId: q1.id,
        random: Random(42),
      );
      expect(q2.id, isNot(equals(q1.id)));
      expect(q2.category, equals(IcebreakerCategory.deep));
    });

    testWidgets('IcebreakerSheet renders countdown timer, chips, and next prompt button', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: IcebreakerSheet(
                roomId: 'test_party_room_1',
                currentSpeakerName: 'Host Danial',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('60-Second Icebreaker'), findsOneWidget);
      expect(find.text('Speaker: Host Danial'), findsOneWidget);
      expect(find.text('Reset 60s'), findsOneWidget);
      expect(find.text('Next Prompt'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Fun'), findsOneWidget);
      expect(find.text('Deep'), findsOneWidget);
    });
  });
}
