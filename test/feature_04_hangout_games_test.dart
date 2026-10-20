import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hemiton/models/hangout_game_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/widgets/hangout_games_sheet.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  UserModel get currentUser => const UserModel(
        id: 'user_tester',
        email: 'tester@hemiton.com',
        name: 'Test Gamer',
        username: 'testgamer',
        avatarUrl: 'https://example.com/avatar.png',
      );

  @override
  bool get isAuthenticated => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 4: Interactive Hangout Games Tests', () {
    test('HangoutGamePlayer model JSON serialization and state updates', () {
      final json = {
        'userId': 'p_101',
        'name': 'Gamer One',
        'avatar': 'https://example.com/p1.png',
        'score': 150,
        'isCurrentTurn': true,
        'selectedAnswerIndex': 2,
      };

      final player = HangoutGamePlayer.fromJson(json);
      expect(player.userId, equals('p_101'));
      expect(player.name, equals('Gamer One'));
      expect(player.score, equals(150));
      expect(player.isCurrentTurn, isTrue);
      expect(player.selectedAnswerIndex, equals(2));

      final serialized = player.toJson();
      expect(serialized['score'], equals(150));
      expect(serialized['isCurrentTurn'], isTrue);
    });

    test('HangoutGameState handles multiplayer turn progression and round increments', () {
      final p1 = HangoutGamePlayer(userId: 'u1', name: 'Alice', avatar: '', isCurrentTurn: true);
      final p2 = HangoutGamePlayer(userId: 'u2', name: 'Bob', avatar: '');

      final state = HangoutGameState(
        gameId: 'g_1',
        gameType: HangoutGameType.trivia,
        roomId: 'room_1',
        players: [p1, p2],
        totalRounds: 3,
      );

      expect(state.currentTurnPlayer?.userId, equals('u1'));
      expect(state.currentRound, equals(1));

      // Alice answers and gets 100 points
      state.recordAnswer('u1', 1, 100);
      expect(p1.score, equals(100));

      // Next turn -> Bob
      state.nextTurn();
      expect(state.currentTurnPlayer?.userId, equals('u2'));
      expect(state.currentRound, equals(1));

      // Bob answers and gets 50 points
      state.recordAnswer('u2', 0, 50);
      expect(p2.score, equals(50));

      // Next turn -> cycles back to Alice, increments round to 2
      state.nextTurn();
      expect(state.currentTurnPlayer?.userId, equals('u1'));
      expect(state.currentRound, equals(2));
      expect(state.leadingPlayer?.userId, equals('u1'));
    });

    test('Curated Trivia and Truth or Dare datasets integrity', () {
      expect(HangoutTriviaQuestion.curatedTrivia.isNotEmpty, isTrue);
      for (final q in HangoutTriviaQuestion.curatedTrivia) {
        expect(q.options.length, equals(4));
        expect(q.correctOptionIndex, inInclusiveRange(0, 3));
        expect(q.question.isNotEmpty, isTrue);
      }

      final truth = TruthOrDarePrompt.getRandom(isTruth: true);
      expect(truth.isTruth, isTrue);
      expect(truth.prompt.isNotEmpty, isTrue);

      final dare = TruthOrDarePrompt.getRandom(isTruth: false);
      expect(dare.isTruth, isFalse);
      expect(dare.prompt.isNotEmpty, isTrue);
    });

    testWidgets('HangoutGamesSheet renders Trivia Battle UI and game tabs', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => MockAuthProvider(),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: Scaffold(
                body: HangoutGamesSheet(
                  roomId: 'test_party_room_1',
                  roomTitle: 'Lofi Hangout Lounge',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hangout Trivia Battle'), findsOneWidget);
      expect(find.text('🧠 Trivia Battle'), findsOneWidget);
      expect(find.text('🎭 Truth or Dare'), findsOneWidget);
      expect(find.text('Correct: +100 pts'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
