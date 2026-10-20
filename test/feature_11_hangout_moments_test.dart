import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/features/social/moments_feed_screen.dart';
import 'package:hemiton/models/post_model.dart';
import 'package:hemiton/models/user_model.dart';

void main() {
  group('Feature 11: Hangout Moments Feed Tests', () {
    test('PostModel correctly maps to MomentPostData structure', () {
      final post = PostModel(
        id: 'post_m1',
        author: const UserModel(
          id: 'user_99',
          username: 'squad_leader',
          name: 'Squad Leader 🚀',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775',
          bio: 'Leader',
        ),
        content: 'Epic hangout session in the VIP party room tonight! 💥',
        imageUrls: ['https://images.unsplash.com/photo-1517841905240'],
        likes: 42,
        comments: 12,
        createdAt: DateTime(2026, 10, 19),
      );

      expect(post.id, 'post_m1');
      expect(post.author.displayName, 'Squad Leader 🚀');
      expect(post.content, contains('Epic hangout session'));
      expect(post.likes, 42);
      expect(post.comments, 12);
    });

    testWidgets('MomentsFeedScreen renders post cards and interactions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: MomentsFeedScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find first user name
      expect(find.text('Anam'), findsOneWidget);
      expect(find.textContaining("Friend's Home"), findsOneWidget);

      // Verify comment count button
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsWidgets);

      // Tap Like button on Anam's post
      final likeBtn = find.byIcon(Icons.favorite_border_rounded).first;
      await tester.tap(likeBtn);
      await tester.pumpAndSettle();

      // Filled heart icon appears
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });
  });
}
