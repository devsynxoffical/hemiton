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
    apiKey: 'AIzaSyB05WfZV7Ok55p27jq4OF7bBEIFXjmHftc',
    appId: '1:747197896976:web:f5495d38f2970e0b4c6d95',
    messagingSenderId: '747197896976',
    projectId: 'hemi-ton',
    authDomain: 'hemi-ton.firebaseapp.com',
    storageBucket: 'hemi-ton.firebasestorage.app',
    measurementId: 'G-TBVP0XGS68',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBw2Y_EtAQxpbuxwquLI18YA9DQdkpJ6yw',
    appId: '1:747197896976:android:fd57ff43729d34c34c6d95',
    messagingSenderId: '747197896976',
    projectId: 'hemi-ton',
    storageBucket: 'hemi-ton.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCA8ndLn8mnETXP0m9uPZwdlxpkSrtVv7k',
    appId: '1:747197896976:ios:9d5bef1f4f8af1bb4c6d95',
    messagingSenderId: '747197896976',
    projectId: 'hemi-ton',
    storageBucket: 'hemi-ton.firebasestorage.app',
    iosClientId: '747197896976-tp5o9qg2s0dmcbkmvnlcgge8gr1mtrk6.apps.googleusercontent.com',
    iosBundleId: 'com.hemiton.app',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCA8ndLn8mnETXP0m9uPZwdlxpkSrtVv7k',
    appId: '1:747197896976:ios:eb670c5ca505ca134c6d95',
    messagingSenderId: '747197896976',
    projectId: 'hemi-ton',
    storageBucket: 'hemi-ton.firebasestorage.app',
    iosClientId: '747197896976-fkmq7t6urkb3o6vdsc5i9oi4c0ttkb48.apps.googleusercontent.com',
    iosBundleId: 'com.example.liveStreamApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB05WfZV7Ok55p27jq4OF7bBEIFXjmHftc',
    appId: '1:747197896976:web:4653b410fcad79094c6d95',
    messagingSenderId: '747197896976',
    projectId: 'hemi-ton',
    authDomain: 'hemi-ton.firebaseapp.com',
    storageBucket: 'hemi-ton.firebasestorage.app',
    measurementId: 'G-3Z0W0R1DR2',
  );
}
