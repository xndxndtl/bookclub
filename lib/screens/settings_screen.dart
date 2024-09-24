import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.green),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설정 항목
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green),
              title: Text(
                'App Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // 앱 설정 클릭 시 동작
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.green),
              title: Text(
                'Notifications',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // 알림 설정 클릭 시 동작
              },
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.green),
              title: Text(
                'Privacy & Security',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // 프라이버시 및 보안 클릭 시 동작
              },
            ),
            Divider(color: Colors.grey),
            Spacer(),
            // 로그아웃 버튼
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed('/login'); // 로그아웃 후 로그인 화면으로 이동
                },
                icon: Icon(Icons.logout, color: Colors.black),
                label: Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
