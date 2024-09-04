// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookclub.app/firebase_options.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  /*
  await FirebaseAppCheck.instance.activate(
    // webRecaptchaSiteKey: 'your-site-key',  // 웹인 경우 site-key 필요
    // Android에서는 Play Integrity API 사용 가능
    // androidProvider: AndroidProvider.playIntegrity,
    androidProvider: AndroidProvider.debug, // 앱체크 비활성화
    // appleProvider: AppleProvider.debug,ㅁ
  );
*/

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Club App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),  // AuthWrapper로 네비게이션 로직 추가
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FirebaseAuth를 사용해 현재 로그인된 유저를 확인
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 사용자가 로그인되어 있다면 HomeScreen으로 이동, 아니면 SignInScreen
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return SignInScreen();  // 로그인하지 않은 경우
          } else {
            return HomeScreen();  // 로그인된 경우
          }
        } else {
          // 로딩 화면 표시
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
