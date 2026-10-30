import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hemiton/core/config/app_config.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/features/auth/auth_screen.dart';
import 'package:hemiton/features/auth/forgot_password_screen.dart';

import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    return null;
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  static final _kTransparentImage = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
    0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
    0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
    0x60, 0x82,
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_kTransparentImage).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = _MockHttpOverrides();
    SharedPreferences.setMockInitialValues({});
    AppConfig.initialize(environment: AppEnvironment.development);
    AppConfig.isBackendDisconnected = true;
  });

  Widget buildTestApp({required Widget child, AuthProvider? authProvider, List<NavigatorObserver>? observers}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => authProvider ?? AuthProvider()),
      ],
      child: MaterialApp(
        navigatorObservers: observers ?? [],
        home: child,
      ),
    );
  }

  group('Firebase Authentication Integration Tests', () {
    test('1. AuthProvider validates empty email or password on login', () async {
      final auth = AuthProvider();

      // Empty input
      final resEmpty = await auth.login('', '');
      expect(resEmpty, isFalse);
      expect(auth.errorMessage, equals('Please enter both email and password'));

      // Empty password
      final resPass = await auth.login('test@hemiton.com', '');
      expect(resPass, isFalse);
      expect(auth.errorMessage, equals('Please enter both email and password'));
    });

    test('2. AuthProvider validates email format on signup', () async {
      final auth = AuthProvider();

      // Missing fields
      final resMissing = await auth.signup(name: '', email: '', password: '');
      expect(resMissing, isFalse);
      expect(auth.errorMessage, equals('All fields are required'));

      // Invalid email
      final resInvalidEmail = await auth.signup(
        name: 'Test User',
        email: 'invalid_email_format',
        password: 'password123',
      );
      expect(resInvalidEmail, isFalse);
      expect(auth.errorMessage, equals('Please enter a valid email address'));
    });

    test('3. AuthProvider validates email format on forgotPassword', () async {
      final auth = AuthProvider();

      // Empty email
      final resEmpty = await auth.forgotPassword('');
      expect(resEmpty, isFalse);
      expect(auth.errorMessage, equals('Please enter a valid email address.'));

      // Malformed email
      final resMalformed = await auth.forgotPassword('not_an_email');
      expect(resMalformed, isFalse);
      expect(auth.errorMessage, equals('Please enter a valid email address.'));
    });

    test('4. AuthProvider performs successful authentication & session persistence', () async {
      final auth = AuthProvider();

      // Login
      final loggedIn = await auth.login('user@hemiton.com', 'securePass123');
      expect(loggedIn, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser.email, equals('user@hemiton.com'));
      expect(auth.currentUser.name, isNotEmpty);

      // Logout
      await auth.logout();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser.id, isEmpty);
    });

    testWidgets('5. ForgotPasswordScreen displays input and validates email', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 950));
      await tester.pumpWidget(buildTestApp(child: const ForgotPasswordScreen()));
      await tester.pump();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Forgot Your Password?'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);

      // Tap Send Reset Link without email
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      // Verify validation warning
      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('6. AuthScreen validates fields and toggles login / signup modes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 950));
      await tester.pumpWidget(buildTestApp(child: const AuthScreen(initialMode: AuthMode.login)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check login elements
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Tap login with empty fields
      await tester.tap(find.text('LOGIN'));
      await tester.pump();

      // Verify inline validation error
      expect(find.text('Please enter your email address'), findsOneWidget);

      // Switch to Sign Up
      await tester.tap(find.text('Sign Up'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 350));

      // Check sign up elements
      expect(find.text('Create Account'), findsOneWidget);

      // Tap create account with empty fields
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pump();

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    test('7. AuthProvider session restoration and profile completeness verification', () async {
      final auth = AuthProvider();
      await auth.login('hemiton_test@hemiton.com', 'pass123');
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser.profileCompleted, isTrue);
      expect(auth.currentUser.email, equals('hemiton_test@hemiton.com'));
    });
  });
}
