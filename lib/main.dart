// lib/main.dart
/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookclub.app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'screens/nickname_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check

  await FirebaseAppCheck.instance.activate(
    // webRecaptchaSiteKey: 'your-site-key',  // 웹인 경우 site-key 필요
    // Android에서는 Play Integrity API 사용 가능
    androidProvider: AndroidProvider.playIntegrity,
    // androidProvider: AndroidProvider.debug, // 앱체크 비활성화
    // appleProvider: AppleProvider.debug
  );


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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return SignInScreen(); // 로그인하지 않은 경우
          } else {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasData && userSnapshot.data != null) {
                  // Firestore에서 닉네임 확인
                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  if (userData.containsKey('nickname') && userData['nickname'] != null) {
                    return HomeScreen(); // 닉네임이 있는 경우 홈 화면으로 이동
                  } else {
                    return NicknameScreen(); // 닉네임이 없으면 닉네임 입력 화면으로 이동
                  }
                } else {
                  return NicknameScreen(); // 사용자 데이터가 없으면 닉네임 입력 화면으로 이동
                }
              },
            );
          }
        } else {
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
*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookclub.app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookclub.app/screens/sign_in_screen.dart';
import 'package:bookclub.app/screens/home_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:bookclub.app/screens/nickname_screen.dart';
import 'package:bookclub.app/screens/welcome_screen.dart'; // WelcomeScreen 임포트


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

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
      // 처음 화면은 WelcomeScreen으로 설정
      home: WelcomeScreen(),
    );
  }
}
