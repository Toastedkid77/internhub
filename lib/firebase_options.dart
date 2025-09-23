import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFrzqcvjkk2XakVEEn6jnPnSjqCVnEBF4',
    appId: '1:984853624177:android:6ccbb3efc2615f451232d0',
    messagingSenderId: '984853624177',
    projectId: 'inthub-f9371',
    storageBucket: 'inthub-f9371.firebasestorage.app',
  );
}

