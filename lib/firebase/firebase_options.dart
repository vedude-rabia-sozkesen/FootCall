// File: lib/firebase/firebase_options.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyANN31PrgtwfICM5hDEPu2I4S769KlJm_k',
    appId: '1:863663672688:web:6d890d4fee18a9d9cc13b5',
    messagingSenderId: '863663672688',
    projectId: 'footcall',
    authDomain: 'footcall.firebaseapp.com',
    storageBucket: 'footcall.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANN31PrgtwfICM5hDEPu2I4S769KlJm_k',
    appId: '1:863663672688:android:6d890d4fee18a9d9cc13b5',
    messagingSenderId: '863663672688',
    projectId: 'footcall',
    storageBucket: 'footcall.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANN31PrgtwfICM5hDEPu2I4S769KlJm_k',
    appId: '1:863663672688:ios:6d890d4fee18a9d9cc13b5',
    messagingSenderId: '863663672688',
    projectId: 'footcall',
    storageBucket: 'footcall.firebasestorage.app',
    iosBundleId: 'com.example.projectPages',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANN31PrgtwfICM5hDEPu2I4S769KlJm_k',
    appId: '1:863663672688:ios:6d890d4fee18a9d9cc13b5',
    messagingSenderId: '863663672688',
    projectId: 'footcall',
    storageBucket: 'footcall.firebasestorage.app',
    iosBundleId: 'com.example.projectPages',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyANN31PrgtwfICM5hDEPu2I4S769KlJm_k',
    appId: '1:863663672688:web:6d890d4fee18a9d9cc13b5',
    messagingSenderId: '863663672688',
    projectId: 'footcall',
    authDomain: 'footcall.firebaseapp.com',
    storageBucket: 'footcall.firebasestorage.app',
  );
}