import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/social_provider.dart';
import 'package:hemiton/providers/wallet_provider.dart';
import 'package:hemiton/features/home/home_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  testWidgets('Recommended, Moments & Friends Tabs and Floating Action Button visibility test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SocialProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify tabs exist
    expect(find.text('Recommend'), findsOneWidget);
    expect(find.text('Moments'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);

    // 2. On initial load, Recommended tab (tab 0) is active -> Floating (+) Button MUST be present
    final fabFinder = find.byKey(const ValueKey('home_floating_add_button'));
    expect(fabFinder, findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // 3. Tap on Moments tab (tab 1)
    await tester.tap(find.byKey(const ValueKey('header_tab_1')));
    await tester.pump(const Duration(milliseconds: 350));

    // Floating (+) Button MUST be completely hidden on Moments
    expect(find.byKey(const ValueKey('home_floating_add_button')), findsNothing);
    expect(find.byKey(const ValueKey('empty_fab')), findsOneWidget);

    // 4. Swipe from Moments to Friends tab (tab 2)
    await tester.drag(find.byType(PageView).first, const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Floating (+) Button MUST be completely hidden on Friends
    expect(find.byKey(const ValueKey('home_floating_add_button')), findsNothing);
    expect(find.byKey(const ValueKey('empty_fab')), findsOneWidget);

    // Verify Active Friends section exists in Friends tab
    expect(find.text('Active Friends'), findsOneWidget);
    expect(find.text('Online Now'), findsOneWidget);
    expect(find.text('Find Friends'), findsOneWidget);

    // 5. Tap back to Recommend tab (tab 0) from top header
    final recommendTabFinder = find.byKey(const ValueKey('header_tab_0'));
    await tester.tap(recommendTabFinder);
    await tester.pumpAndSettle();

    // Floating (+) Button MUST reappear immediately on Recommend
    expect(find.byKey(const ValueKey('home_floating_add_button')), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
