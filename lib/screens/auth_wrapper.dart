import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sign_in_screen.dart';
import 'home_screen.dart';
import 'nickname_screen.dart';

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
