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
