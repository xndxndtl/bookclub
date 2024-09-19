/*
// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text('User Profile : '),
      ),
    );
  }
}

 */

// lib/screens/profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nicknameController = TextEditingController();
  bool _isEditing = false;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 현재 로그인된 사용자의 프로필 정보를 불러오는 함수
  Future<void> _loadProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nickname = userDoc['nickname'];
          _nicknameController.text = _nickname!;
        });
      }
    }
  }

  // 닉네임을 업데이트하는 함수
  Future<void> _updateNickname() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'nickname': _nicknameController.text,
      });
      setState(() {
        _nickname = _nicknameController.text;
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            _isEditing
                ? TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Nickname',
                border: OutlineInputBorder(),
              ),
            )
                : Text(
              _nickname ?? 'Loading...',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            _isEditing
                ? ElevatedButton(
              onPressed: _updateNickname,
              child: Text('Save Nickname'),
            )
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: Text('Edit Nickname'),
            ),
          ],
        ),
      ),
    );
  }
}

