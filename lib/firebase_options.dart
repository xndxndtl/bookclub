// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyDkA7FLtkwoat95qMQ4hHb9WFhQjJtOPNI',
    appId: '1:604987238080:web:fd2131bba690386ec02f25',
    messagingSenderId: '604987238080',
    projectId: 'bookclub-8e08d',
    authDomain: 'bookclub-8e08d.firebaseapp.com',
    storageBucket: 'bookclub-8e08d.appspot.com',
    measurementId: 'G-E29KH32CCJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAc61Hf1DdK32mDrxYjDNXR4HeNNiIKR2I',
    appId: '1:604987238080:android:52762004090472b7c02f25',
    messagingSenderId: '604987238080',
    projectId: 'bookclub-8e08d',
    storageBucket: 'bookclub-8e08d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCAmj3VtK0Eso_nwEagry2H_ffwjHhJdwA',
    appId: '1:604987238080:ios:1faf6b8a96fdc30cc02f25',
    messagingSenderId: '604987238080',
    projectId: 'bookclub-8e08d',
    storageBucket: 'bookclub-8e08d.appspot.com',
    iosBundleId: 'com.example.bookclub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCAmj3VtK0Eso_nwEagry2H_ffwjHhJdwA',
    appId: '1:604987238080:ios:1faf6b8a96fdc30cc02f25',
    messagingSenderId: '604987238080',
    projectId: 'bookclub-8e08d',
    storageBucket: 'bookclub-8e08d.appspot.com',
    iosBundleId: 'com.example.bookclub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDkA7FLtkwoat95qMQ4hHb9WFhQjJtOPNI',
    appId: '1:604987238080:web:083df67a7b86536ec02f25',
    messagingSenderId: '604987238080',
    projectId: 'bookclub-8e08d',
    authDomain: 'bookclub-8e08d.firebaseapp.com',
    storageBucket: 'bookclub-8e08d.appspot.com',
    measurementId: 'G-HJ4NW08VRN',
  );
}
