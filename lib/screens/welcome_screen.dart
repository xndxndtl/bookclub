import 'package:flutter/material.dart';
import 'auth_wrapper.dart'; // AuthWrapper로의 네비게이션

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // 세로축 중앙 정렬
          crossAxisAlignment: CrossAxisAlignment.center, // 가로축 중앙 정렬
          children: [
            // 이미지 추가 (로컬 이미지 사용)
            Image.asset(
              'assets/images/book_club.png', // 로컬 이미지 경로
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'BookClub',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Connect with book lovers',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // 'Get Started' 버튼을 누르면 AuthWrapper로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthWrapper()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Get started',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
