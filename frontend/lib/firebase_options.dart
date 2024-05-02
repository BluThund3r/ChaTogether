// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD5S3ZAtN99xlYFyZ8gskmSIrM4IwckhSo',
    appId: '1:414330706451:web:9146c2a9bb3910a9a8bde6',
    messagingSenderId: '414330706451',
    projectId: 'chatogether-cc587',
    authDomain: 'chatogether-cc587.firebaseapp.com',
    storageBucket: 'chatogether-cc587.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXHVTSx9IKn_c3QAM6oO7X3cbcgpQagzQ',
    appId: '1:414330706451:android:ba659b608b65aa23a8bde6',
    messagingSenderId: '414330706451',
    projectId: 'chatogether-cc587',
    storageBucket: 'chatogether-cc587.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_InVznKd7lZOgx7qXKuH9DF9zw3Kzebk',
    appId: '1:414330706451:ios:b7f2d7ea36a670bda8bde6',
    messagingSenderId: '414330706451',
    projectId: 'chatogether-cc587',
    storageBucket: 'chatogether-cc587.appspot.com',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_InVznKd7lZOgx7qXKuH9DF9zw3Kzebk',
    appId: '1:414330706451:ios:bd5c1f579a409f1fa8bde6',
    messagingSenderId: '414330706451',
    projectId: 'chatogether-cc587',
    storageBucket: 'chatogether-cc587.appspot.com',
    iosBundleId: 'com.example.frontend.RunnerTests',
  );
}
