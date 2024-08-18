// lib/screens/add_member_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMemberScreen extends StatefulWidget {
  final String clubId;

  AddMemberScreen({required this.clubId});

  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addMember() async {
    try {
      // 입력된 이메일로 사용자를 Firestore에서 찾기
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (userQuery.docs.isEmpty) {
        // 사용자가 없는 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found with this email.')),
        );
        return;
      }

      // 사용자가 있는 경우
      String userId = userQuery.docs.first.id;

      // 클럽 문서의 members 배열에 사용자 추가
      await _firestore.collection('clubs').doc(widget.clubId).update({
        'members': FieldValue.arrayUnion([userId])
      });

      // 사용자의 joinedClubs 배열에 클럽 추가
      await _firestore.collection('users').doc(userId).update({
        'joinedClubs': FieldValue.arrayUnion([widget.clubId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member added successfully!')),
      );

      Navigator.pop(context); // 화면 종료
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add member. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Enter member email'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addMember,
              child: Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}
