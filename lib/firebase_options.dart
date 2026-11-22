// PLACEHOLDER - run `flutterfire configure` in the project root.
// That command overwrites this file with your real Firebase project values.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
            'Run `flutterfire configure` for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAEYnrjBsixIPnlSqdZ_KnGmtPQGH-en1Y',
    appId: '1:665172290860:web:3dc7d79edafc6420165089',
    messagingSenderId: '665172290860',
    projectId: 'intentflow-3c492',
    authDomain: 'intentflow-3c492.firebaseapp.com',
    storageBucket: 'intentflow-3c492.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAj8VGYjtD9xSQ4f7DLoYycNkl0POvPgzA',
    appId: '1:665172290860:android:ecc95ef23e249ae6165089',
    messagingSenderId: '665172290860',
    projectId: 'intentflow-3c492',
    storageBucket: 'intentflow-3c492.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1yMIExYrCmr9RAgUfJusZlGwTvHYssC8',
    appId: '1:665172290860:ios:1c77971fc180267a165089',
    messagingSenderId: '665172290860',
    projectId: 'intentflow-3c492',
    storageBucket: 'intentflow-3c492.firebasestorage.app',
    iosBundleId: 'com.example.intentflow',
  );
}
