// lib/screens/sign_in_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email'
  ]);

  /*
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["profile", "email"]);
  */
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signInWithGoogle() async {
    try {
      final UserCredential userCredential = await AuthService().signInWithGoogle();
      if (userCredential.user != null) {
        await saveUserData(userCredential.user!);  // 사용자 데이터 저장
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),  // 로그인 후 홈 화면으로 이동
        );
      }
    } catch (e) {
      print("Failed to sign in with Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in with Google. Please try again!'))
      );
    }
  }

  Future<void> saveUserData(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'lastSignIn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Failed to save user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Your email",
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // 이메일 및 패스워드로 로그인 로직 추가 가능
              },
              child: Text("SIGN IN"),
            ),
            TextButton(
              onPressed: () {
                // 비밀번호 재설정 또는 회원가입 로직 추가
              },
              child: Text("Forgot password?"),
            ),
            TextButton(
              onPressed: () {
                // 회원가입 화면 이동 로직 추가
              },
              child: Text("New to Bookclubs? Create Your Account"),
            ),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text("Continue with Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Facebook 로그인 로직 추가
              },
              child: Text("Continue with Facebook"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
