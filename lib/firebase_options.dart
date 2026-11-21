import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Values extracted from `google-services.json`.
/// For the web platform, you must also register a Web App in the
/// Firebase console and paste the web-specific values below.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android (from google-services.json) ──────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0pOsTtXR6s9fmXgRgvAxrUGSRKJ14p6E',
    appId: '1:704177767512:android:52ec35e91b41c4fa45362d',
    messagingSenderId: '704177767512',
    projectId: 'strat3x-app',
    storageBucket: 'strat3x-app.firebasestorage.app',
  );

  // ── Web ──────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcsSsjj0TyrzfcUxUwGebR0EsFYBzkVPg',
    appId: '1:704177767512:web:067205084ec2cab245362d',
    messagingSenderId: '704177767512',
    projectId: 'strat3x-app',
    storageBucket: 'strat3x-app.firebasestorage.app',
    authDomain: 'strat3x-app.firebaseapp.com',
    measurementId: 'G-QKTQ6CZ5PK',
  );

  // ── iOS (fill in when you have GoogleService-Info.plist) ─────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0pOsTtXR6s9fmXgRgvAxrUGSRKJ14p6E',
    appId: '1:704177767512:android:52ec35e91b41c4fa45362d', // Replace with iOS appId
    messagingSenderId: '704177767512',
    projectId: 'strat3x-app',
    storageBucket: 'strat3x-app.firebasestorage.app',
  );
}
