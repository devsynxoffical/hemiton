// File placeholder for new Firebase project.
// Run `flutterfire configure` to generate your new Firebase configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] placeholder for HEMI TON.
/// Will be replaced automatically when you run:
///   flutterfire configure
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can configure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Placeholder options: Run `flutterfire configure` to connect your new Firebase project
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_FIREBASE_APP_ID',
    messagingSenderId: '000000000000',
    projectId: 'new-hemiton-project',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_FIREBASE_APP_ID',
    messagingSenderId: '000000000000',
    projectId: 'new-hemiton-project',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_FIREBASE_APP_ID',
    messagingSenderId: '000000000000',
    projectId: 'new-hemiton-project',
    iosBundleId: 'com.hemiton.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_FIREBASE_APP_ID',
    messagingSenderId: '000000000000',
    projectId: 'new-hemiton-project',
    iosBundleId: 'com.hemiton.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_FIREBASE_APP_ID',
    messagingSenderId: '000000000000',
    projectId: 'new-hemiton-project',
  );
}
