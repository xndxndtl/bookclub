import 'package:bookclub.app/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NicknameScreen extends StatefulWidget {
  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isSaving = false;

  void _saveNickname() async {
    setState(() {
      _isSaving = true;
    });

    String nickname = _nicknameController.text.trim();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (nickname.isNotEmpty) {
      // Firestore에 닉네임 저장
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'nickname': nickname,
      });

      // 저장 후 메인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Nickname'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Enter your nickname',
              ),
            ),
            SizedBox(height: 20),
            _isSaving
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveNickname,
              child: Text('Save Nickname'),
            ),
          ],
        ),
      ),
    );
  }
}
